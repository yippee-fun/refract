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
				| \[\]=? | [+\-]@? | [~!] | \*\*? | [/%&|^`] | <=> | ===? | =~ | !~ | != | <[<=]? | >[>=]?
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
		REGEXP_INTERPOLATION = %r{#(?=\{|@@?(?:[A-Za-z_]|[^\x00-\x7F])|\$(?:[A-Za-z_~*$?!@/\\;,.=:<>"&`'+\d]|-\w|[^\x00-\x7F]|\z))}

		ESCAPE_PATTERNS = {
			'"' => /[\\"]|#(?=[{@$])|[^[:print:]]/,
			"`" => /[\\`]|#(?=[{@$])|[^[:print:]]/,
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
			@buffer = []
			@source_map = []
			@inferred_lines = Set.new
			@current_line = starting_line
			@indent = 0
			@shareable_constant_value = :none
		end

		def around_visit(node, &)
			value = shareable_constant_value_within(node) if statement?(node)

			if value && (value != :none || @shareable_constant_value != :none)
				shareable_constant_value(value) { map_source_and_visit(node, &) }
			else
				map_source_and_visit(node, &)
			end
		end

		def visit_each(nodes)
			nodes = nodes.compact
			last = nodes.length - 1

			nodes.each_with_index do |node, index|
				length = @buffer.length
				visit node
				yield if block_given? && index < last && @buffer.length > length
			end
		end

		def format_node(node)
			visit(node)

			Result.new(
				source: @buffer.join,
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
			visit node.left
			space
			push node.operator
			space
			visit node.right
		end

		visit ArgumentsNode do |node|
			visit_each(node.arguments) { push ", " }
		end

		visit ArrayNode do |node|
			brackets do
				indent do
					visit_each(node.elements) { push ","; new_line }
				end
				new_line
			end
		end

		visit ArrayPatternNode do |node|
			visit node.constant
			brackets do
				visit_each([*node.requireds, node.rest, *node.posts]) { push ", " }
			end
		end

		visit AssocNode do |node|
			case node.key
			when SymbolNode
				bare = !node.key.quoted && bare?(node.key.unescaped, LABEL)
				push(bare ? node.key.unescaped : quote(node.key.unescaped))
				push ":"

				if ImplicitNode === node.value && bare && shorthand?(node.key, node.value.value)
					visit node.value
				else
					space
					visit((ImplicitNode === node.value) ? node.value.value : node.value)
				end
			else
				visit node.key
				push " => "
				visit node.value
			end
		end

		visit AssocSplatNode do |node|
			push "**"
			visit node.value
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
			visit node.expression
		end

		visit BlockLocalVariableNode do |node|
			push node.name
		end

		visit BlockNode do |node|
			braces do
				case node.parameters
				when nil
					nil
				when ItParametersNode, NumberedParametersNode
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
			visit node.value
		end

		visit CallNode do |node|
			arguments = node.arguments&.arguments

			if node.attribute_write && node.block.nil? && arguments
				if node.name == :[]= && !node.safe_navigation
					*index, value = arguments
					parenthesize(low_precedence?(node.receiver)) { visit node.receiver }
					brackets { visit_each(index) { push ", " } }
					push " = "
					visit value
					return
				elsif node.name.match?(SETTER) && arguments.length == 1
					call_receiver(node)
					push node.name.name.delete_suffix("=")
					push " = "
					visit arguments.first
					return
				end
			end

			call_receiver(node)
			push node.name

			case node.block
			when BlockNode
				if node.arguments
					parens { visit node.arguments }
				end

				space
				visit node.block
			when BlockArgumentNode
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
			visit node.value
		end

		visit CallOrWriteNode do |node|
			call_receiver(node)
			push node.read_name
			push " ||= "
			visit node.value
		end

		visit CallTargetNode do |node|
			if node.receiver
				visit node.receiver
				push "."
			end

			push node.name[0..-2]
		end

		visit CapturePatternNode do |node|
			visit node.value
			push " => "
			visit node.target
		end

		visit CaseMatchNode do |node|
			push "case "
			visit node.predicate
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
			visit node.predicate
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
				visit node.superclass
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
			visit node.value
		end

		visit ClassVariableOperatorWriteNode do |node|
			push node.name
			push " #{node.binary_operator}= "
			visit node.value
		end

		visit ClassVariableOrWriteNode do |node|
			push node.name
			push " ||= "
			visit node.value
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
			visit node.value
		end

		visit ConstantAndWriteNode do |node|
			push node.name
			push " &&= "
			visit node.value
		end

		visit ConstantOperatorWriteNode do |node|
			push node.name
			push " #{node.binary_operator}= "
			visit node.value
		end

		visit ConstantOrWriteNode do |node|
			push node.name
			push " ||= "
			visit node.value
		end

		visit ConstantPathAndWriteNode do |node|
			visit node.target
			push " &&= "
			visit node.value
		end

		visit ConstantPathNode do |node|
			visit node.parent
			push "::"
			push node.name
		end

		visit ConstantPathOperatorWriteNode do |node|
			visit node.target
			space
			push node.binary_operator
			push "= "
			visit node.value
		end

		visit ConstantPathOrWriteNode do |node|
			visit node.target
			push " ||= "
			visit node.value
		end

		visit ConstantPathTargetNode do |node|
			visit node.parent if node.parent
			push "::" if node.parent
			push node.name
		end

		visit ConstantPathWriteNode do |node|
			visit node.target
			push " = "
			visit node.value
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
			visit node.value
		end

		visit DefNode do |node|
			push "def"
			space

			if node.receiver
				visit node.receiver
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
				visit node.value
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
			visit node.left
			push node.exclude_end ? "..." : ".."
			visit node.right
		end

		visit FloatNode do |node|
			push node.value.to_s
		end

		visit ForNode do |node|
			push "for"
			space
			visit node.index
			push " in "
			visit node.collection
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
			visit node.value
		end

		visit GlobalVariableOperatorWriteNode do |node|
			push node.name
			space
			push node.binary_operator
			push "= "
			visit node.value
		end

		visit GlobalVariableOrWriteNode do |node|
			push node.name
			push " ||= "
			visit node.value
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
			visit node.value
		end

		visit HashNode do |node|
			braces do
				indent do
					visit_each(node.elements) { push ","; new_line }
				end

				new_line
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
			if node.inline
				visit node.statements
				push " if "
				visit node.predicate
			elsif (IfNode === @stack[-2]) && @stack[-2].subsequent.equal?(node)
				push "elsif "
				visit node.predicate
				if node.statements
					indent do
						visit node.statements
					end
				end
				if node.subsequent
					new_line
					visit node.subsequent
				end
			else
				parenthesize(modifier_ambiguous?) do
					push "if "
					visit node.predicate
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
		end

		visit ImaginaryNode do |node|
			visit node.numeric
			push "i"
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
			if node.statements
				indent do
					visit node.statements
				end
			end
		end

		visit IndexAndWriteNode do |node|
			visit node.receiver
			push "["
			visit_each([node.arguments, node.block]) { push ", " }
			push "] &&= "
			visit node.value
		end

		visit IndexOperatorWriteNode do |node|
			visit node.receiver
			push "["
			visit_each([node.arguments, node.block]) { push ", " }
			push "] "
			push node.binary_operator
			push "= "
			visit node.value
		end

		visit IndexOrWriteNode do |node|
			visit node.receiver
			push "["
			visit_each([node.arguments, node.block]) { push ", " }
			push "] ||= "
			visit node.value
		end

		visit IndexTargetNode do |node|
			visit node.receiver
			push "["
			visit_each([node.arguments, node.block]) { push ", " }
			push "]"
		end

		visit InstanceVariableAndWriteNode do |node|
			push node.name
			push " &&= "
			visit node.value
		end

		visit InstanceVariableOperatorWriteNode do |node|
			push node.name
			space
			push node.binary_operator
			push "= "
			visit node.value
		end

		visit InstanceVariableOrWriteNode do |node|
			push node.name
			push " ||= "
			visit node.value
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
			visit node.value
		end

		visit IntegerNode do |node|
			push node.value.to_s
		end

		visit InterpolatedMatchLastLineNode do |node|
			push "/"
			visit_parts(node.parts) { |string| push escape_regexp(string) }
			push "/"
			regexp_flags(node)
		end

		visit InterpolatedRegularExpressionNode do |node|
			push "/"
			visit_parts(node.parts) { |string| push escape_regexp(string) }
			push "/"
			regexp_flags(node)
		end

		visit InterpolatedStringNode do |node|
			doubles do
				visit_parts(node.parts) { |string| push escape_string(string, '"') }
			end
		end

		visit InterpolatedSymbolNode do |node|
			push ":"
			doubles do
				visit_parts(node.parts) { |string| push escape_string(string, '"') }
			end
		end

		visit InterpolatedXStringNode do |node|
			push "`"
			visit_parts(node.parts) { |string| push escape_string(string, "`") }
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
			when nil
				nil
			when ItParametersNode, NumberedParametersNode
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
			visit node.value
		end

		visit LocalVariableOperatorWriteNode do |node|
			push node.name
			space
			push node.binary_operator
			push "= "
			visit node.value
		end

		visit LocalVariableOrWriteNode do |node|
			push node.name
			push " ||= "
			visit node.value
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
			visit node.value
		end

		visit MatchLastLineNode do |node|
			push "/"
			push escape_regexp(node.unescaped)
			push "/"
			regexp_flags(node)
		end

		visit MatchPredicateNode do |node|
			visit node.value
			push " in "
			visit node.pattern
		end

		visit MatchRequiredNode do |node|
			visit node.value
			push " => "
			visit node.pattern
		end

		visit MatchWriteNode do |node|
			visit node.call.receiver
			push " =~ "
			visit node.call.arguments
		end

		visit MissingNode do |node|
			# Missing nodes represent syntax errors - output nothing
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
			parenthesize(!(ForNode === @stack[-2])) do
				visit_each([*node.lefts, node.rest, *node.rights]) { push ", " }
			end
		end

		visit MultiWriteNode do |node|
			visit_each([*node.lefts, node.rest, *node.rights]) { push ", " }
			space unless ImplicitRestNode === node.rest
			push "= "
			visit node.value
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
			visit node.value
		end

		visit OptionalParameterNode do |node|
			push node.name
			push " = "
			visit node.value
		end

		visit OrNode do |node|
			visit node.left
			space
			push node.operator
			space
			visit node.right
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
			@escape_non_ascii = node.encoding && node.encoding != Encoding::UTF_8

			if node.encoding && node.encoding != Encoding::UTF_8
				push "# encoding: #{node.encoding.name}"
				new_line
			end

			unless node.frozen_string_literal.nil?
				push "# frozen_string_literal: #{node.frozen_string_literal}"
				new_line
			end

			visit node.statements
		end

		visit RangeNode do |node|
			visit node.left
			push node.exclude_end ? "..." : ".."
			visit node.right
		end

		visit RationalNode do |node|
			push rational(node.numerator, node.denominator)
		end

		visit RedoNode do |node|
			push "redo"
		end

		visit RegularExpressionNode do |node|
			push "/"
			push escape_regexp(node.unescaped)
			push "/"
			regexp_flags(node)
		end

		visit RequiredKeywordParameterNode do |node|
			push node.name
			push ":"
		end

		visit RequiredParameterNode do |node|
			push node.name
		end

		visit RescueModifierNode do |node|
			visit node.expression
			push " rescue "
			visit node.rescue_expression
		end

		visit RescueNode do |node|
			push "rescue"
			if node.exceptions&.any?
				space
				visit_each(node.exceptions) { push ", " }
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
			if @stack.length == 1
				shareable_constant_value(node.value) { visit node.write }
			else
				visit node.write
			end
		end

		visit SingletonClassNode do |node|
			push "class << "
			visit node.expression

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
			push node.start_line&.to_s || "__LINE__"
		end

		visit SplatNode do |node|
			push "*"
			visit node.expression
		end

		visit StatementsNode do |node|
			visit_each(flatten_statements(node.body)) { new_line }
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
			if node.inline
				visit node.statements
				push " unless "
				visit node.predicate
			else
				parenthesize(modifier_ambiguous?) do
					push "unless "
					visit node.predicate

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
		end

		visit UntilNode do |node|
			if node.inline
				visit node.statements
				push " until "
				visit node.predicate
			else
				parenthesize(modifier_ambiguous?) do
					push "until "
					visit node.predicate
					if node.statements
						indent do
							visit node.statements
						end
					end
					new_line
					push "end"
				end
			end
		end

		visit WhenNode do |node|
			push "when"
			space
			visit_each(node.conditions) { push ", " }
			indent do
				visit node.statements
			end
		end

		visit WhileNode do |node|
			if node.inline
				visit node.statements
				push " while "
				visit node.predicate
			else
				parenthesize(modifier_ambiguous?) do
					push "while "
					visit node.predicate
					if node.statements
						indent do
							visit node.statements
						end
					end
					new_line
					push "end"
				end
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
			when String
				value
			when Symbol
				value.name
			end

			@current_line += string.count("\n") if string
			@buffer << string
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

		private def outdent
			return yield if @indent == 0
			@indent -= 1
			new_line
			yield
			@indent += 1
			nil
		end

		private def parens
			push "("
			yield
			push ")"
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

		private def rational(numerator, denominator)
			rest, twos, fives = denominator, 0, 0
			(rest /= 2) && (twos += 1) while rest.even?
			(rest /= 5) && (fives += 1) while (rest % 5).zero?
			return "(#{numerator}r/#{denominator})" unless rest == 1

			places = [twos, fives].max
			digits = (numerator.abs * (10 ** places) / denominator).to_s.rjust(places + 1, "0")
			sign = numerator.negative? ? "-" : ""

			if places.zero?
				"#{sign}#{digits}r"
			else
				"#{sign}#{digits[0...-places]}.#{digits[-places..]}r"
			end
		end

		private def shorthand?(key, value)
			case value
			when LocalVariableReadNode, LocalVariableTargetNode, ConstantReadNode
				value.name.name == key.unescaped
			when CallNode
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
			when IfNode, UnlessNode, WhileNode, UntilNode
				parent.inline
			when ParenthesesNode, EmbeddedStatementsNode
				true
			else
				false
			end
		end

		private def shareable_constant_value_within(node)
			case node
			when ShareableConstantNode
				return node.value
			when ConstantWriteNode, ConstantOrWriteNode, ConstantAndWriteNode, ConstantOperatorWriteNode,
					ConstantPathWriteNode, ConstantPathOrWriteNode, ConstantPathAndWriteNode, ConstantPathOperatorWriteNode

				return :none
			end

			node.class.attributes.each do |name|
				Array(node.public_send(name)).each do |child|
					next unless Node === child
					next if StatementsNode === child && !inline_statements?(node)

					value = shareable_constant_value_within(child)
					return value if value
				end
			end

			nil
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
			name.valid_encoding? && (name.ascii_only? || !@escape_non_ascii) && name.match?(pattern)
		end

		private def low_precedence?(node)
			case node
			when AndNode, OrNode, RescueModifierNode, RangeNode, FlipFlopNode, MatchPredicateNode, MatchRequiredNode, ShareableConstantNode
				true
			when IfNode, UnlessNode, WhileNode, UntilNode
				node.inline
			when CallNode
				node.attribute_write
			else
				node.type.end_with?("write_node")
			end
		end

		private def call_receiver(node)
			return unless node.receiver

			parenthesize(low_precedence?(node.receiver)) { visit node.receiver }
			push "&" if node.safe_navigation
			push "."
		end

		private def parenthesize(condition, &)
			condition ? parens(&) : yield
		end

		# `return`, `break`, `next` and `rescue` are complete on their own, so a
		# keyword expression after them would be read as a modifier.
		private def modifier_ambiguous?
			case @stack[-2]
			when RescueNode
				true
			when RescueModifierNode
				@stack[-2].rescue_expression.equal?(@stack[-1])
			when ArgumentsNode
				ReturnNode === @stack[-3] || BreakNode === @stack[-3] || NextNode === @stack[-3]
			else
				false
			end
		end

		private def quote(string)
			if string.include?('"') && string.valid_encoding? && (string.ascii_only? || !@escape_non_ascii) && !string.match?(/['\\]|[^[:print:]]/)
				"'#{string}'"
			else
				%("#{escape_string(string, '"')}")
			end
		end

		private def escape_string(string, delimiter)
			string = string.b unless string.encoding == Encoding::UTF_8 && string.valid_encoding?

			pattern = ESCAPE_PATTERNS.fetch(delimiter)
			pattern = Regexp.union(pattern, NON_ASCII) if @escape_non_ascii

			string.gsub(pattern) do |char|
				if (escape = STRING_ESCAPES[char])
					escape
				elsif char.bytesize == 1 && char.match?(/[[:print:]]/)
					"\\#{char}"
				elsif char.bytesize == 1
					format("\\x%02X", char.ord)
				else
					format("\\u{%X}", char.ord)
				end
			end
		end

		private def escape_regexp(string)
			string = string.b unless string.valid_encoding?
			string.gsub(%r{\\.|/|#{REGEXP_INTERPOLATION}}m) { |match| (match.length == 2) ? match : "\\#{match}" }
		end

		private def regexp_flags(node)
			push "i" if node.ignore_case
			push "m" if node.multi_line
			push "x" if node.extended
			push "o" if node.once
			push REGEXP_ENCODINGS.fetch(node.encoding) if node.encoding
		end

		private def visit_parts(parts)
			flatten_parts(parts)
				.chunk_while { |a, b| StringNode === a && StringNode === b }
				.each do |chunk|
					if StringNode === chunk.first
						yield chunk.map(&:unescaped).join
					else
						visit chunk.first
					end
				end
		end

		private def flatten_statements(body)
			body.flat_map { |statement| (StatementsNode === statement) ? flatten_statements(statement.body) : statement }
		end

		private def flatten_parts(parts)
			parts.flat_map { |part| (InterpolatedStringNode === part) ? flatten_parts(part.parts) : part }
		end
	end
end
