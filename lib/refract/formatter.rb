# frozen_string_literal: true

module Refract
	class Formatter < BasicVisitor
		Result = Data.define(:source, :source_map)

		IDENTIFIER = /(?:[A-Za-z_]|[^\x00-\x7F])(?:\w|[^\x00-\x7F])*/
		BARE_IDENTIFIER = /\A#{IDENTIFIER}\z/
		SETTER = /\A#{IDENTIFIER}=\z/
		LABEL = /\A#{IDENTIFIER}[?!]?\z/
		BARE_SYMBOL = %r{
			\A(?:
				#{IDENTIFIER}[?!=]?
				| @@?#{IDENTIFIER}
				| \$(?:#{IDENTIFIER}|-\w|\d+|[~*$?!@/\\;,.=:<>"&`'+])
				| \[\]=? | [+-]@? | [~!] | \*\*? | [/%&|^`] | <=> | ===? | =~ | !~ | != | <[<=]? | >[>=]?
			)\z
		}x

		STRING_ESCAPES = {
			"\n" => "\\n",
			"\t" => "\\t",
			"\r" => "\\r",
			"\f" => "\\f",
			"\v" => "\\v",
			"\a" => "\\a",
			"\b" => "\\b",
			"\e" => "\\e",
		}.freeze

		# In a regexp, `#` only needs escaping where it would start interpolation.
		# The end of the source counts, since the closing `/` can form `$/`.
		REGEXP_INTERPOLATION = %r{#(?=\{|@@?(?:[A-Za-z_]|[^\x00-\x7F])|\$(?:[A-Za-z_~*$?!@/\\;,.=:<>"&`'+\d]|-(?:\w|[^\x00-\x7F])|[^\x00-\x7F]|\z))}

		ESCAPE_PATTERNS = {
			'"' => /[\\"]|#(?=[{@$])|[^[:print:]]/,
			"`" => /[\\`]|#(?=[{@$])|[^[:print:]]/,
			"]" => /[\\\[\]\s]|#(?=[{@$])|[^[:print:]]/,
		}.freeze

		NON_ASCII = /[^\x00-\x7F]/

		REGEXP_ENCODINGS = {
			ascii_8bit: "n",
			euc_jp: "e",
			windows_31j: "s",
			utf_8: "u",
		}.freeze

		def initialize(starting_line: 1)
			super()
			@starting_line = starting_line
		end

		def around_visit(node, &)
			if (value = shareable_constant_value_for(node))
				multiline_parens(@stack.length > 1 && !statement?(node)) do
					shareable_constant_value(value) { map_source_and_visit(node, &) }
				end
			else
				map_source_and_visit(node, &)
			end
		end

		def visit_each(nodes, &separator)
			separate(nodes, separator) { |node| visit node }
		end

		def format_node(node)
			@buffer = []
			@source_map = []
			@inferred_lines = Set.new
			@current_line = @starting_line
			@indent = 0
			@shareable_constant_value = :none
			@encoding = node&.prism_node&.slice&.encoding || Encoding::UTF_8

			visit(node)

			Result.new(
				source: join(@buffer),
				source_map: @source_map,
			)
		end

		visit AliasGlobalVariableNode do |node|
			push "alias"
			space
			visit node.new_name
			space
			visit node.old_name
		end

		visit AliasMethodNode do |node|
			push "alias"
			space
			visit node.new_name
			space
			visit node.old_name
		end

		visit AlternationPatternNode do |node|
			visit node.left
			push " | "
			visit node.right
		end

		visit AndNode do |node|
			operand node.left
			space
			push node.operator
			space
			operand node.right
		end

		visit ArgumentsNode do |node|
			visit_operands(node.arguments, after_keyword: (@stack[-2] in ReturnNode | BreakNode | NextNode)) { push ", " }
		end

		visit ArrayNode do |node|
			elements = Array(node.elements)

			if pattern? && (prefix = word_list_prefix(elements))
				word_list(prefix, elements)
			else
				pinned(pattern?) do
					brackets do
						indent do
							visit_operands(elements) { push ","; new_line }
						end
						new_line
					end
				end
			end
		end

		visit ArrayPatternNode do |node|
			visit node.constant
			brackets do
				visit_each([*node.requireds, node.rest, *node.posts]) { push ", " }
			end
		end

		visit AssocNode do |node|
			pattern = HashPatternNode === @stack[-2]

			case node.key
			in SymbolNode unless leading_jump_argument?
				bare = !node.key.quoted && bare?(node.key.unescaped, LABEL)
				push(bare ? node.key.unescaped : quote(node.key.unescaped))
				push ":"

				if ImplicitNode === node.value && (bare || pattern) && shorthand?(node.key, node.value.value)
					return visit node.value
				end

				space
				value = (ImplicitNode === node.value) ? node.value.value : node.value
			else
				operand node.key
				push " => "
				value = (ImplicitNode === node.value) ? node.value.value : node.value
			end

			pattern ? visit(value) : operand(value)
		end

		visit AssocSplatNode do |node|
			push "**"
			operand node.value
		end

		visit BackReferenceReadNode do |node|
			push node.name
		end

		visit BeginNode do |node|
			push "begin"

			indent do
				visit node.statements
			end

			new_line

			if node.rescue_clause
				visit node.rescue_clause
				new_line
			end

			if node.else_clause
				visit node.else_clause
				new_line
			end

			if node.ensure_clause
				visit node.ensure_clause
				new_line
			end

			push "end"
		end

		visit BlockArgumentNode do |node|
			push "&"
			operand node.expression
		end

		visit BlockLocalVariableNode do |node|
			push node.name
		end

		visit BlockNode do |node|
			braces do
				case node.parameters
				in nil
					nil
				in ItParametersNode | NumberedParametersNode
					visit node.parameters
				else
					space
					pipes do
						visit node.parameters
					end
				end

				indent do
					visit node.body
				end

				new_line
			end
		end

		visit BlockParameterNode do |node|
			push "&"
			push node.name
		end

		visit BlockParametersNode do |node|
			visit node.parameters

			if node.locals&.any?
				push "; "
				visit_each(node.locals) { push ", " }
			end
		end

		visit BreakNode do |node|
			push "break"
			if node.arguments
				space
				visit node.arguments
			end
		end

		visit CallAndWriteNode do |node|
			call_receiver(node)
			push node.read_name
			push " &&= "
			operand node.value
		end

		visit CallNode do |node|
			if not?(node)
				push "!"
				return operand node.receiver
			end

			if setter?(node)
				case [node.receiver, node.arguments&.arguments, node.block]
				in [Node, [Node => value], nil] unless value in SplatNode | KeywordHashNode | BlockArgumentNode
					call_receiver(node)
					push node.name.name.delete_suffix("=")
					push " = "
					return operand value
				else
					raise ArgumentError, "A call to #{node.name} needs a receiver, one positional argument and no block."
				end
			elsif index_write?(node)
				*index, value = node.arguments.arguments
				receiver node.receiver
				brackets { visit_operands(index) { push ", " } }
				push " = "
				return operand value
			end

			call_receiver(node)
			push node.name

			case node.block
			in BlockNode
				if node.arguments
					parens { visit node.arguments }
				end

				space
				visit node.block
			in BlockArgumentNode
				parens do
					if node.arguments
						visit node.arguments
						push ", "
					end

					visit node.block
				end
			else
				if node.arguments
					parens { visit node.arguments }
				elsif !node.receiver && !node.variable_call && node.name.match?(BARE_IDENTIFIER)
					push "()"
				end
			end
		end

		visit CallOperatorWriteNode do |node|
			call_receiver(node)
			push node.read_name
			space
			push node.binary_operator
			push "= "
			operand node.value
		end

		visit CallOrWriteNode do |node|
			call_receiver(node)
			push node.read_name
			push " ||= "
			operand node.value
		end

		visit CallTargetNode do |node|
			receiver node.receiver
			push(node.safe_navigation ? "&." : ".")
			push node.name.name.delete_suffix("=")
		end

		visit CapturePatternNode do |node|
			visit node.value
			push " => "
			visit node.target
		end

		visit CaseMatchNode do |node|
			push "case "
			operand node.predicate
			new_line
			visit_each(node.conditions) { new_line }
			new_line
			if node.else_clause
				visit node.else_clause
				new_line
			end
			push "end"
		end

		visit CaseNode do |node|
			push "case "
			operand node.predicate
			new_line
			visit_each(node.conditions) { new_line }
			new_line
			if node.else_clause
				visit node.else_clause
				new_line
			end
			push "end"
		end

		visit ClassNode do |node|
			push "class"
			space
			visit node.constant_path
			if node.superclass
				push " < "
				operand node.superclass
			end
			if node.body
				indent do
					visit node.body
				end
			end
			new_line
			push "end"
		end

		visit ClassVariableAndWriteNode do |node|
			push node.name
			push " &&= "
			operand node.value
		end

		visit ClassVariableOperatorWriteNode do |node|
			push node.name
			push " #{node.binary_operator}= "
			operand node.value
		end

		visit ClassVariableOrWriteNode do |node|
			push node.name
			push " ||= "
			operand node.value
		end

		visit ClassVariableReadNode do |node|
			push node.name
		end

		visit ClassVariableTargetNode do |node|
			push node.name
		end

		visit ClassVariableWriteNode do |node|
			push node.name
			push " = "
			operand node.value
		end

		visit ConstantAndWriteNode do |node|
			push node.name
			push " &&= "
			operand node.value
		end

		visit ConstantOperatorWriteNode do |node|
			push node.name
			push " #{node.binary_operator}= "
			operand node.value
		end

		visit ConstantOrWriteNode do |node|
			push node.name
			push " ||= "
			operand node.value
		end

		visit ConstantPathAndWriteNode do |node|
			visit node.target
			push " &&= "
			operand node.value
		end

		visit ConstantPathNode do |node|
			receiver node.parent
			push "::"
			push node.name
		end

		visit ConstantPathOperatorWriteNode do |node|
			visit node.target
			space
			push node.binary_operator
			push "= "
			operand node.value
		end

		visit ConstantPathOrWriteNode do |node|
			visit node.target
			push " ||= "
			operand node.value
		end

		visit ConstantPathTargetNode do |node|
			receiver node.parent
			push "::"
			push node.name
		end

		visit ConstantPathWriteNode do |node|
			visit node.target
			push " = "
			operand node.value
		end

		visit ConstantReadNode do |node|
			push node.name
		end

		visit ConstantTargetNode do |node|
			push node.name
		end

		visit ConstantWriteNode do |node|
			push node.name
			push " = "
			operand node.value
		end

		visit DefNode do |node|
			push "def"
			space

			if node.receiver
				parenthesize(!(node.receiver in SelfNode | LocalVariableReadNode | InstanceVariableReadNode | ClassVariableReadNode | GlobalVariableReadNode | ConstantReadNode | ParenthesesNode | CallNode[variable_call: true])) do
					operand node.receiver
				end
				push "."
			end

			push node.name

			if node.parameters
				parens do
					visit node.parameters
				end
			end

			if node.body
				indent do
					visit node.body
				end
			end

			new_line

			push "end"
		end

		visit DefinedNode do |node|
			push "defined?"
			parens do
				operand node.value
			end
		end

		visit ElseNode do |node|
			push "else"

			indent do
				visit node.statements
			end
		end

		visit EmbeddedStatementsNode do |node|
			push "\#{"
			visit node.statements
			push "}"
		end

		visit EmbeddedVariableNode do |node|
			push "#"
			visit node.variable
		end

		visit EnsureNode do |node|
			push "ensure"

			indent do
				visit node.statements
			end
		end

		visit FalseNode do |node|
			push "false"
		end

		visit FindPatternNode do |node|
			visit node.constant
			brackets do
				visit_each([node.left, *node.requireds, node.right]) { push ", " }
			end
		end

		visit FlipFlopNode do |node|
			if condition
				range(node)
			else
				push "(("
				range(node)
				push ") ? true : false)"
			end
		end

		visit FloatNode do |node|
			case node.value
			in String => value
				push value
			in Float => value if value.nan?
				push "::Float::NAN"
			in Float => value if value.infinite?
				value.positive? ? push("::Float::INFINITY") : expression { push "-::Float::INFINITY" }
			in Float => value
				push value.to_s
			end
		end

		visit ForNode do |node|
			push "for"
			space
			visit node.index
			push " in "
			operand node.collection
			indent do
				visit node.statements
			end
			new_line
			push "end"
		end

		visit ForwardingArgumentsNode do |node|
			push "..."
		end

		visit ForwardingParameterNode do |node|
			push "..."
		end

		visit ForwardingSuperNode do |node|
			push "super"
			visit node.block if node.block
		end

		visit GlobalVariableAndWriteNode do |node|
			push node.name
			push " &&= "
			operand node.value
		end

		visit GlobalVariableOperatorWriteNode do |node|
			push node.name
			space
			push node.binary_operator
			push "= "
			operand node.value
		end

		visit GlobalVariableOrWriteNode do |node|
			push node.name
			push " ||= "
			operand node.value
		end

		visit GlobalVariableReadNode do |node|
			push node.name
		end

		visit GlobalVariableTargetNode do |node|
			push node.name
		end

		visit GlobalVariableWriteNode do |node|
			push node.name
			push " = "
			operand node.value
		end

		visit HashNode do |node|
			pinned(pattern?) do
				braces do
					indent do
						visit_each(node.elements) { push ","; new_line }
					end

					new_line
				end
			end
		end

		visit HashPatternNode do |node|
			if node.constant
				visit node.constant
				brackets do
					visit_each([*node.elements, node.rest]) { push ", " }
				end
			else
				braces do
					space
					visit_each([*node.elements, node.rest]) { push ", " }
					space
				end
			end
		end

		visit IfNode do |node|
			if (IfNode === @stack[-2]) && @stack[-2].subsequent.equal?(node)
				push "elsif "
				operand node.predicate
				if node.statements
					indent do
						visit node.statements
					end
				end
				if node.subsequent
					new_line
					visit node.subsequent
				end
			elsif modifier?(node)
				modifier(node, "if")
			else
				push "if "
				operand node.predicate
				if node.statements
					indent do
						visit node.statements
					end
				end
				if node.subsequent
					new_line
					visit node.subsequent
				end
				new_line
				push "end"
			end
		end

		visit ImaginaryNode do |node|
			case node.numeric
			in RationalNode
				map_source_and_visit(node.numeric) { rational(node.numeric, "ri") }
			in FloatNode[value: Float => value] unless value.finite?
				expression do
					push "::Complex.rectangular(0, "
					visit node.numeric
					push ")"
				end
			else
				visit node.numeric
				push "i"
			end
		end

		visit ImplicitNode do |node|
			nil
		end

		visit ImplicitRestNode do |node|
			nil
		end

		visit InNode do |node|
			push "in "
			visit node.pattern
			push " then" if endless?(node.pattern)
			if node.statements
				indent do
					visit node.statements
				end
			end
		end

		visit IndexAndWriteNode do |node|
			receiver node.receiver
			push "["
			visit_each([node.arguments, node.block]) { push ", " }
			push "] &&= "
			operand node.value
		end

		visit IndexOperatorWriteNode do |node|
			receiver node.receiver
			push "["
			visit_each([node.arguments, node.block]) { push ", " }
			push "] "
			push node.binary_operator
			push "= "
			operand node.value
		end

		visit IndexOrWriteNode do |node|
			receiver node.receiver
			push "["
			visit_each([node.arguments, node.block]) { push ", " }
			push "] ||= "
			operand node.value
		end

		visit IndexTargetNode do |node|
			receiver node.receiver
			push "["
			visit_each([node.arguments, node.block]) { push ", " }
			push "]"
		end

		visit InstanceVariableAndWriteNode do |node|
			push node.name
			push " &&= "
			operand node.value
		end

		visit InstanceVariableOperatorWriteNode do |node|
			push node.name
			space
			push node.binary_operator
			push "= "
			operand node.value
		end

		visit InstanceVariableOrWriteNode do |node|
			push node.name
			push " ||= "
			operand node.value
		end

		visit InstanceVariableReadNode do |node|
			push node.name
		end

		visit InstanceVariableTargetNode do |node|
			push node.name
		end

		visit InstanceVariableWriteNode do |node|
			push node.name
			push " = "
			operand node.value
		end

		visit IntegerNode do |node|
			push node.value.to_s
		end

		visit InterpolatedMatchLastLineNode do |node|
			regexp(node) { visit_parts(node.parts) { |string| escape_regexp(string) } }
			push ".=~($_)" unless condition
		end

		visit InterpolatedRegularExpressionNode do |node|
			unconditional(condition(any_parser: true)) do
				regexp(node) { visit_parts(node.parts) { |string| escape_regexp(string) } }
			end
		end

		visit InterpolatedStringNode do |node|
			doubles do
				visit_parts(node.parts) { |string| escape_string(string, '"') }
			end
		end

		visit InterpolatedSymbolNode do |node|
			push ":"
			doubles do
				visit_parts(node.parts) { |string| escape_string(string, '"') }
			end
		end

		visit InterpolatedXStringNode do |node|
			push "`"
			visit_parts(node.parts) { |string| escape_string(string, "`") }
			push "`"
		end

		visit ItLocalVariableReadNode do |node|
			push "it"
		end

		visit ItParametersNode do |node|
			nil
		end

		visit KeywordHashNode do |node|
			visit_each(node.elements) { push ", " }
		end

		visit KeywordRestParameterNode do |node|
			push "**"
			push node.name
		end

		visit LambdaNode do |node|
			push "->"

			case node.parameters
			in nil
				nil
			in ItParametersNode | NumberedParametersNode
				visit node.parameters
			else
				space

				parens do
					visit node.parameters
				end
			end

			space

			braces do
				indent do
					visit node.body
				end

				new_line
			end
		end

		visit LocalVariableAndWriteNode do |node|
			push node.name
			push " &&= "
			operand node.value
		end

		visit LocalVariableOperatorWriteNode do |node|
			push node.name
			space
			push node.binary_operator
			push "= "
			operand node.value
		end

		visit LocalVariableOrWriteNode do |node|
			push node.name
			push " ||= "
			operand node.value
		end

		visit LocalVariableReadNode do |node|
			push node.name
		end

		visit LocalVariableTargetNode do |node|
			push node.name
		end

		visit LocalVariableWriteNode do |node|
			push node.name
			push " = "
			operand node.value
		end

		visit MatchLastLineNode do |node|
			regexp(node) { push escape_regexp(node.unescaped) }
			push ".=~($_)" unless condition
		end

		visit MatchPredicateNode do |node|
			parenthesize(endless?(node.pattern)) do
				operand node.value
				push " in "
				visit node.pattern
			end
		end

		visit MatchRequiredNode do |node|
			parenthesize(endless?(node.pattern)) do
				operand node.value
				push " => "
				visit node.pattern
			end
		end

		visit MatchWriteNode do |node|
			start = @buffer.length
			visit node.call.receiver
			names = Array(node.targets).map(&:name)
			captures = Prism.parse("#{join(@buffer[start..])} =~ nil", scopes: [names], encoding: @encoding).value.statements.body.first
			captured = (captures in Prism::MatchWriteNode[targets:]) ? targets.map(&:name) : []

			unless names == captured
				raise ArgumentError, "MatchWriteNode targets #{names} must match the regexp's named captures #{captured}."
			end

			push " =~ "
			visit node.call.arguments
		end

		visit MissingNode do |node|
			raise ArgumentError, "Can't format a MissingNode. The source it came from has a syntax error."
		end

		visit ModuleNode do |node|
			push "module"
			space
			visit node.constant_path
			if node.body
				indent do
					visit node.body
				end
			end
			new_line
			push "end"
		end

		visit MultiTargetNode do |node|
			targets = [*node.lefts, node.rest, *node.rights].compact

			parenthesize(!(ForNode === @stack[-2]) || MultiTargetNode === targets.first) do
				visit_each(targets) { push ", " }
			end
		end

		visit MultiWriteNode do |node|
			targets = [*node.lefts, node.rest, *node.rights].compact
			parenthesize((targets in [MultiTargetNode])) { visit_each(targets) { push ", " } }
			space unless ImplicitRestNode === node.rest
			push "= "
			operand node.value
		end

		visit NextNode do |node|
			push "next"
			if node.arguments
				space
				visit node.arguments
			end
		end

		visit NilNode do |node|
			push "nil"
		end

		visit NoKeywordsParameterNode do |node|
			push "**nil"
		end

		visit NumberedParametersNode do |node|
			nil
		end

		visit NumberedReferenceReadNode do |node|
			push "$#{node.number}"
		end

		visit OptionalKeywordParameterNode do |node|
			push node.name
			push ": "
			operand node.value
		end

		visit OptionalParameterNode do |node|
			push node.name
			push " = "
			operand node.value
		end

		visit OrNode do |node|
			operand node.left
			space
			push node.operator
			space
			operand node.right
		end

		visit ParametersNode do |node|
			visit_each([
				*node.requireds,
				*node.optionals,
				node.rest,
				*node.posts,
				*node.keywords,
				node.keyword_rest,
				node.block,
			]) { push ", " }
		end

		visit ParenthesesNode do |node|
			parens do
				visit node.body
			end
		end

		visit PinnedExpressionNode do |node|
			push "^("
			visit node.expression
			push ")"
		end

		visit PinnedVariableNode do |node|
			push "^"
			visit node.variable
		end

		visit PostExecutionNode do |node|
			push "END {"
			indent do
				visit node.statements
			end
			new_line
			push "}"
		end

		visit PreExecutionNode do |node|
			push "BEGIN {"
			indent do
				visit node.statements
			end
			new_line
			push "}"
		end

		visit ProgramNode do |node|
			@encoding = node.encoding if node.encoding

			if escape_non_ascii?
				push "# encoding: #{@encoding.name}"
				new_line
			end

			unless node.frozen_string_literal.nil?
				push "# frozen_string_literal: #{node.frozen_string_literal}"
				new_line
			end

			visit node.statements
		end

		visit RangeNode do |node|
			unconditional(condition(any_parser: true)) do
				(pattern? && !literal_ends?(node)) ? expression { range(node) } : range(node)
			end
		end

		visit RationalNode do |node|
			rational(node, "r")
		end

		visit RedoNode do |node|
			push "redo"
		end

		visit RegularExpressionNode do |node|
			unconditional(condition(any_parser: true)) do
				regexp(node) { push escape_regexp(node.unescaped) }
			end
		end

		visit RequiredKeywordParameterNode do |node|
			push node.name
			push ":"
		end

		visit RequiredParameterNode do |node|
			push node.name
		end

		visit RescueModifierNode do |node|
			operand node.expression
			push " rescue "
			operand(node.rescue_expression, after_keyword: true)
		end

		visit RescueNode do |node|
			push "rescue"
			if node.exceptions&.any?
				space
				visit_operands(node.exceptions, after_keyword: true) { push ", " }
			end

			if node.reference
				push " => "
				visit node.reference
			end

			if node.statements
				indent do
					visit node.statements
				end
			end

			if node.subsequent
				new_line
				visit node.subsequent
			end
		end

		visit RestParameterNode do |node|
			push "*"
			push node.name
		end

		visit RetryNode do |node|
			push "retry"
		end

		visit ReturnNode do |node|
			push "return"
			if node.arguments
				space
				visit node.arguments
			end
		end

		visit SelfNode do |node|
			push "self"
		end

		visit ShareableConstantNode do |node|
			visit node.write
		end

		visit SingletonClassNode do |node|
			push "class << "
			operand node.expression

			if node.body
				indent do
					visit node.body
				end
			end

			new_line
			push "end"
		end

		visit SourceEncodingNode do |node|
			push "__ENCODING__"
		end

		visit SourceFileNode do |node|
			push "__FILE__"
		end

		visit SourceLineNode do |node|
			unconditional(condition(any_parser: true) == :flip_flop) { push node.start_line&.to_s || "__LINE__" }
		end

		visit SplatNode do |node|
			push "*"
			operand node.expression
		end

		visit StatementsNode do |node|
			visit_each(each_statement(node.body).to_a) { new_line }
		end

		visit StringNode do |node|
			push quote(node.unescaped)
		end

		visit SuperNode do |node|
			push "super"

			parens do
				visit_each([node.arguments, (node.block if BlockArgumentNode === node.block)]) { push ", " }
			end

			if BlockNode === node.block
				space
				visit node.block
			end
		end

		visit SymbolNode do |node|
			push ":"
			if node.quoted || !bare?(node.unescaped, BARE_SYMBOL)
				push quote(node.unescaped)
			else
				push node.unescaped
			end
		end

		visit TrueNode do |node|
			push "true"
		end

		visit UndefNode do |node|
			push "undef"
			space
			visit_each(node.names) { push ", " }
		end

		visit UnlessNode do |node|
			if modifier?(node)
				modifier(node, "unless")
			else
				push "unless "
				operand node.predicate

				if node.statements
					indent do
						visit node.statements
					end
				end

				if node.else_clause
					new_line
					visit node.else_clause
				end

				new_line
				push "end"
			end
		end

		visit UntilNode do |node|
			if modifier?(node)
				modifier(node, "until")
			else
				push "until "
				operand node.predicate
				if node.statements
					indent do
						visit node.statements
					end
				end
				new_line
				push "end"
			end
		end

		visit WhenNode do |node|
			push "when"
			space
			visit_operands(node.conditions) { push ", " }
			indent do
				visit node.statements
			end
		end

		visit WhileNode do |node|
			if modifier?(node)
				modifier(node, "while")
			else
				push "while "
				operand node.predicate
				if node.statements
					indent do
						visit node.statements
					end
				end
				new_line
				push "end"
			end
		end

		visit XStringNode do |node|
			push "`"
			push escape_string(node.unescaped, "`")
			push "`"
		end

		visit YieldNode do |node|
			push "yield"
			if node.arguments
				parens do
					visit node.arguments
				end
			end
		end

		private def push(value)
			string = case value
			in String
				value
			in Symbol
				value.name
			else
				return
			end

			@current_line += string.count("\n")
			@buffer << string
		end

		# Strings in other encodings, or with invalid bytes, are written as bytes.
		private def join(strings)
			strings.map(&:b).join.force_encoding(@encoding)
		end

		private def escape_non_ascii?
			@encoding != Encoding::UTF_8
		end

		private def space
			push " "
		end

		private def new_line
			@buffer << "\n#{"\t" * @indent}"
			@current_line += 1
		end

		private def indent
			@indent += 1
			new_line
			yield
			@indent -= 1
			nil
		end

		private def parens
			push "("
			yield
			push ")"
		end

		private def multiline_parens(condition, &)
			return yield unless condition

			parens do
				indent(&)
				new_line
			end
		end

		private def braces
			push "{"
			yield
			push "}"
		end

		private def brackets
			push "["
			yield
			push "]"
		end

		private def pipes
			push "|"
			yield
			push "|"
		end

		private def doubles
			push '"'
			yield
			push '"'
		end

		private def rational(node, suffix)
			numerator, denominator = node.numerator, node.denominator
			places = decimal_places(denominator)
			return expression { push "#{numerator}#{suffix}/#{denominator}" } unless places

			digits = (numerator.abs * (10 ** places) / denominator).to_s.rjust(places + 1, "0")
			sign = numerator.negative? ? "-" : ""

			if places.zero?
				push "#{sign}#{digits}#{suffix}"
			else
				push "#{sign}#{digits[0...-places]}.#{digits[-places..]}#{suffix}"
			end
		end

		# A value written as an expression rather than a literal, pinned in a pattern.
		private def expression(&)
			push "^" if pattern?
			parens(&)
		end

		# A range in a pattern can only have literals at its ends, so is otherwise pinned whole.
		private def literal_ends?(range)
			literal?(range.left) && literal?(range.right)
		end

		private def literal?(node)
			case node
			in FloatNode[value: Float => value]
				value.finite?
			in RationalNode
				!decimal_places(node.denominator).nil?
			in ImaginaryNode
				literal?(node.numeric)
			else
				true
			end
		end

		# How many decimal places a fraction with this denominator needs, or nil if it repeats.
		private def decimal_places(denominator)
			rest, twos, fives = denominator, 0, 0
			(rest /= 2) && (twos += 1) while rest.even?
			(rest /= 5) && (fives += 1) while (rest % 5).zero?
			[twos, fives].max if rest == 1
		end

		# `return a: 1` doesn't parse, though `return :a => 1` does.
		private def leading_jump_argument?
			case @stack[-4..-2]
			in [ReturnNode | BreakNode | NextNode, ArgumentsNode => arguments, KeywordHashNode => hash]
				arguments.arguments.first.equal?(hash)
			else
				false
			end
		end

		private def shorthand?(key, value)
			case value
			in LocalVariableReadNode | LocalVariableTargetNode | ConstantReadNode
				value.name.name == key.unescaped
			in CallNode
				value.name.name == key.unescaped && !value.receiver && !value.arguments && !value.block
			else
				false
			end
		end

		# The outermost located node that starts on a line claims it. A node
		# without a location only fills an unclaimed line, with the line of its
		# nearest located ancestor, until a located node starts there.
		private def map_source_and_visit(node)
			if (start_line = node.start_line)
				if @source_map[@current_line].nil? || @inferred_lines.delete?(@current_line)
					@source_map[@current_line] = start_line
				end
			elsif @source_map[@current_line].nil? && (start_line = @stack.reverse_each.lazy.filter_map(&:start_line).first)
				@source_map[@current_line] = start_line
				@inferred_lines << @current_line
			end

			yield(node)
		end

		# A statement on lines of its own, so a magic comment can go before and after it.
		private def statement?(node)
			StatementsNode === @stack[-2] && !inline_statements?(@stack[-3])
		end

		private def inline_statements?(parent)
			case parent
			in ParenthesesNode | EmbeddedStatementsNode
				true
			else
				modifier?(parent)
			end
		end

		# A statement takes the setting of its constant writes when they agree.
		# Otherwise each write that differs from the setting in force gets its own.
		private def shareable_constant_value_for(node)
			if statement?(node)
				values = shareable_constant_values_within(node, @stack[-2])

				if values.one? && (values.first != :none || @shareable_constant_value != :none)
					return values.first
				end
			end

			value = own_shareable_constant_value(node, @stack[-2])
			value unless value == @shareable_constant_value
		end

		private def own_shareable_constant_value(node, parent)
			case node
			in ShareableConstantNode
				node.value
			in ConstantWriteNode | ConstantOrWriteNode | ConstantAndWriteNode | ConstantOperatorWriteNode |
					ConstantPathWriteNode | ConstantPathOrWriteNode | ConstantPathAndWriteNode | ConstantPathOperatorWriteNode
				:none unless ShareableConstantNode === parent
			else
				nil
			end
		end

		private def shareable_constant_values_within(node, parent, values = Set.new)
			value = own_shareable_constant_value(node, parent)
			values << value if value

			node.class.attributes.each do |name|
				Array(node.public_send(name)).each do |child|
					next unless Node === child
					next if StatementsNode === child && !inline_statements?(node)

					shareable_constant_values_within(child, node, values)
				end
			end

			values
		end

		private def shareable_constant_value(value)
			previous = @shareable_constant_value
			@shareable_constant_value = value

			push "# shareable_constant_value: #{value}"
			new_line
			yield
			new_line
			push "# shareable_constant_value: #{previous}"
		ensure
			@shareable_constant_value = previous
		end

		private def bare?(name, pattern)
			name.valid_encoding? && (name.ascii_only? || !escape_non_ascii?) && name.match?(pattern)
		end

		# Anything that binds more loosely than a method argument.
		private def compound?(node)
			case node
			in AndNode | OrNode | RescueModifierNode | RangeNode | FlipFlopNode | MatchPredicateNode | MatchRequiredNode | MatchWriteNode |
					MultiWriteNode | ShareableConstantNode | ReturnNode | BreakNode | NextNode | AliasMethodNode | AliasGlobalVariableNode | UndefNode

				true
			in CallNode
				setter?(node) || index_write?(node)
			in nil
				false
			else
				modifier?(node) || node.type.end_with?("write_node")
			end
		end

		private def modifier?(node)
			case node
			in IfNode[inline: true, statements: StatementsNode, subsequent: nil] | UnlessNode[inline: true, statements: StatementsNode, else_clause: nil]
				true
			in WhileNode[inline: true, statements: StatementsNode] | UntilNode[inline: true, statements: StatementsNode]
				true
			else
				false
			end
		end

		private def setter?(node)
			node.name.match?(SETTER) && (node.receiver || node.arguments)
		end

		private def index_write?(node)
			node.name == :[]= && node.attribute_write && node.block.nil? && node.arguments && !node.safe_navigation
		end

		private def not?(node)
			node in CallNode[name: :!, receiver: Node, arguments: nil, block: nil, safe_navigation: false | nil]
		end

		# Whether a node's source starts with `if`, `unless`, `while` or `until`,
		# which straight after `return`, `break`, `next` or `rescue` is a modifier.
		private def starts_with_condition?(node)
			case node
			in IfNode | UnlessNode | WhileNode | UntilNode
				!modifier?(node)
			in CallNode
				!not?(node) && starts_with_condition?(node.receiver)
			in ConstantPathNode
				starts_with_condition?(node.parent)
			else
				false
			end
		end

		private def operand(node, after_keyword: false)
			if StatementsNode === node
				multiline_parens(true) { visit node }
			else
				parenthesize(compound?(node) || (after_keyword && starts_with_condition?(node))) { visit node }
			end
		end

		private def receiver(node)
			not?(node) ? parens { visit node } : operand(node)
		end

		private def visit_operands(nodes, after_keyword: false, &separator)
			separate(nodes, separator) { |node| operand(node, after_keyword:) }
		end

		# A node that printed nothing gets no separator.
		private def separate(nodes, separator)
			nodes = Array(nodes).compact
			last = nodes.length - 1

			nodes.each_with_index do |node, index|
				length = @buffer.length
				yield node
				separator&.call if index < last && @buffer.length > length
			end
		end

		private def modifier(node, keyword)
			if each_statement(node.statements.body).one?
				visit node.statements
			else
				multiline_parens(true) { visit node.statements }
			end

			push " #{keyword} "
			operand node.predicate
		end

		private def call_receiver(node)
			return unless node.receiver

			receiver node.receiver
			push "&" if node.safe_navigation
			push "."
		end

		private def parenthesize(condition, &)
			condition ? parens(&) : yield
		end

		private def pinned(condition, &)
			return yield unless condition

			push "^"
			parens(&)
		end

		# Every Ruby reads `(x if true)` as a value, even where a range would be a
		# flip-flop or a regexp a match against `$_`.
		private def unconditional(condition)
			return yield unless condition

			parens do
				yield
				push " if true"
			end
		end

		# Where Ruby reads a range as a flip-flop and a regexp as a match against
		# `$_`, with every parser or, given `any_parser`, with at least one. At the
		# ends of a flip-flop, an integer is compared with `$.`. Unlike Prism,
		# Ruby 3.3's parser reads the last of several statements as a condition, but
		# not the body of a `begin` with `rescue` or `ensure`.
		private def condition(index = @stack.length - 1, any_parser: false)
			return if index < 1

			node, parent = @stack[index], @stack[index - 1]

			case parent
			in IfNode | UnlessNode | WhileNode | UntilNode
				:condition if parent.predicate.equal?(node)
			in CallNode
				:condition if not?(parent)
			in AndNode | OrNode
				:condition if condition(index - 1, any_parser:)
			in FlipFlopNode
				:flip_flop
			in ParenthesesNode
				condition(index - 1, any_parser:)
			in BeginNode
				if parent.statements.equal?(node) && (any_parser || (parent in BeginNode[rescue_clause: nil, else_clause: nil, ensure_clause: nil]))
					condition(index - 1, any_parser:)
				end
			in StatementsNode
				if each_statement(parent.body).one? || (any_parser && last_statement(node).equal?(last_statement(parent.body)))
					condition(index - 1, any_parser:)
				end
			else
				nil
			end
		end

		private def pattern?(index = @stack.length - 1)
			return false if index < 1

			node, parent = @stack[index], @stack[index - 1]

			case parent
			in InNode | MatchPredicateNode | MatchRequiredNode
				parent.pattern.equal?(node)
			in ArrayPatternNode | FindPatternNode | AlternationPatternNode
				true
			in CapturePatternNode
				parent.value.equal?(node)
			in AssocNode
				HashPatternNode === @stack[index - 2] && parent.value.equal?(node)
			in ParenthesesNode
				pattern?(index - 1)
			in RangeNode
				literal_ends?(parent) && pattern?(index - 1)
			in StatementsNode
				each_statement(parent.body).one? && pattern?(index - 1)
			in IfNode | UnlessNode
				parent.statements.equal?(node) && pattern?(index - 1)
			else
				false
			end
		end

		private def endless?(pattern)
			case pattern
			in RangeNode
				pattern.right.nil?
			in AlternationPatternNode
				endless?(pattern.right)
			in StatementsNode
				(each_statement(pattern.body).first(2) in [statement]) && endless?(statement)
			else
				false
			end
		end

		private def range(node)
			parenthesize(node.right.nil? && !pattern?) do
				operand node.left
				push node.exclude_end ? "..." : ".."
				operand node.right
			end
		end

		private def word_list_prefix(elements)
			if elements.all? { |element| word?(element, StringNode, InterpolatedStringNode) }
				"%W["
			elsif elements.all? { |element| word?(element, SymbolNode, InterpolatedSymbolNode) }
				"%I["
			end
		end

		private def word?(node, plain, interpolated)
			case node
			in ^plain
				!node.unescaped.empty?
			in ^interpolated
				flatten_parts(node.parts).any? { |part| !(part in StringNode[unescaped: ""]) }
			else
				false
			end
		end

		private def word_list(prefix, elements)
			push prefix

			elements.each_with_index do |element, index|
				space unless index.zero?

				map_source_and_visit(element) do
					case element
					in StringNode | SymbolNode
						push escape_string(element.unescaped, "]")
					else
						visit_parts(element.parts) { |string| escape_string(string, "]") }
					end
				end
			end

			push "]"
		end

		private def quote(string)
			if string.include?('"') && string.valid_encoding? && (string.ascii_only? || !escape_non_ascii?) && !string.match?(/['\\]|[^[:print:]]/)
				"'#{string}'"
			else
				%("#{escape_string(string, '"')}")
			end
		end

		private def escape_string(string, delimiter)
			string = string.b unless string.encoding == Encoding::UTF_8 && string.valid_encoding?

			pattern = ESCAPE_PATTERNS.fetch(delimiter)
			pattern = Regexp.union(pattern, NON_ASCII) if escape_non_ascii?

			string.gsub(pattern) { |char| escape_character(char) }
		end

		private def escape_character(char)
			if (escape = STRING_ESCAPES[char])
				escape
			elsif char.bytesize > 1
				format("\\u{%X}", char.ord)
			elsif char.match?(/[[:print:]]/)
				"\\#{char}"
			else
				format("\\x%02X", char.ord)
			end
		end

		# Ruby drops a line continuation from a regexp's source, so it can stop a `#`
		# starting interpolation without changing the pattern, whatever the mode.
		private def escape_regexp(string)
			string = string.b unless string.valid_encoding?

			string.gsub(%r{\\.|/|#{REGEXP_INTERPOLATION}}m) do |match|
				case match
				in "/" then "\\/"
				in "#" then "#\\\n"
				else match
				end
			end
		end

		private def regexp(node)
			push "/"
			yield
			push "/"
			push "i" if node.ignore_case
			push "m" if node.multi_line
			push "x" if node.extended
			push "o" if node.once
			push REGEXP_ENCODINGS.fetch(node.encoding) if node.encoding
		end

		# Yields each run of text to be escaped. An embedded variable followed by
		# escaped text that would extend its name is written in braces.
		private def visit_parts(parts)
			chunks = flatten_parts(parts)
				.chunk_while { |a, b| StringNode === a && StringNode === b }
				.map { |chunk| (StringNode === chunk.first) ? yield(chunk.map(&:unescaped).join) : chunk.first }

			chunks.each_with_index do |chunk, index|
				case chunk
				in String
					push chunk
				in EmbeddedVariableNode if extended_by?(chunk.variable, chunks[index + 1])
					visit EmbeddedStatementsNode.new(prism_node: chunk.prism_node, statements: StatementsNode.new(body: [chunk.variable]))
				else
					visit chunk
				end
			end
		end

		# Punctuation variables like `$&` and `$-w` have a fixed length, and `$1` only takes digits.
		private def extended_by?(variable, text)
			case variable
			in NumberedReferenceReadNode
				/\A\d/ === text
			in BackReferenceReadNode
				false
			else
				!variable.name.start_with?("$-") && variable.name.match?(/(?:\w|#{NON_ASCII})\z/) && /\A(?:\w|#{NON_ASCII})/ === text
			end
		end

		private def each_statement(body, &)
			return enum_for(__method__, body) unless block_given?

			Array(body).each do |statement|
				(StatementsNode === statement) ? each_statement(statement.body, &) : yield(statement)
			end
		end

		private def last_statement(body)
			Array(body).reverse_each do |statement|
				last = (StatementsNode === statement) ? last_statement(statement.body) : statement
				return last if last
			end

			nil
		end

		private def flatten_parts(parts)
			Array(parts).flat_map { |part| (InterpolatedStringNode === part) ? flatten_parts(part.parts) : part }
		end
	end
end
