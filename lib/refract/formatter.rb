# frozen_string_literal: true

module Refract
	class Formatter < BasicVisitor
		Result = Data.define(:source, :source_map)

		def initialize(starting_line: 1)
			super()
			@buffer = []
			@source_map = []
			@current_line = starting_line
			@indent = 0
		end

		def around_visit(node)
			if (start_line = node.start_line)
				@source_map[@current_line] = start_line
			end

			super
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
				visit_each(node.requireds) { push ", " }
				visit(node.rest)
			end
		end

		visit AssocNode do |node|
			case node.key
			when SymbolNode
				if node.key.quoted
					doubles do
						push node.key.unescaped.gsub('"', '\"')
					end
				else
					push node.key.unescaped
				end
				push ":"
				space unless ImplicitNode === node.value
				visit node.value
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
			outdent do
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
			if node.receiver
				visit node.receiver
				push "."
			end

			push node.read_name
			space
			push "&&="
			space
			visit node.value
		end

		visit CallNode do |node|
			if node.receiver
				visit node.receiver
				push "."
			end

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
				end
			end
		end

		visit CallOperatorWriteNode do |node|
			if node.receiver
				visit node.receiver
				push "."
			end

			push node.read_name
			space
			push node.binary_operator
			push "="
			space
			visit node.value
		end

		visit CallOrWriteNode do |node|
			if node.receiver
				visit node.receiver
				push "."
			end

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
			braces do
				space
				visit_each([*node.elements, node.rest]) { push ", " }
				space
			end
		end

		visit IfNode do |node|
			if node.inline
				visit node.statements
				push " if "
				visit node.predicate
			else
				# Check if this is an elsif by looking at the parent
				if IfNode === @stack[-2]
					push "elsif "
				else
					push "if "
				end
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
				unless IfNode === @stack[-2]
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
			node.parts.each do |part|
				case part
				when StringNode
					push part.unescaped.gsub("/", "\\/")
				else
					visit part
				end
			end
			push "/"
		end

		visit InterpolatedRegularExpressionNode do |node|
			push "/"
			node.parts.each do |part|
				case part
				when StringNode
					push part.unescaped.gsub("/", "\\/")
				else
					visit part
				end
			end
			push "/"
			push "i" if node.ignore_case
			push "m" if node.multi_line
			push "x" if node.extended
			push "o" if node.once
		end

		visit InterpolatedStringNode do |node|
			doubles do
				node.parts.each do |part|
					case part
					when StringNode
						push part.unescaped.gsub('"', '\"')
					else
						visit part
					end
				end
			end
		end

		visit InterpolatedSymbolNode do |node|
			push ':"'
			node.parts.each do |part|
				case part
				when StringNode
					push part.unescaped.gsub('"', '\"')
				else
					visit part
				end
			end
			push '"'
		end

		visit InterpolatedXStringNode do |node|
			push "`"
			node.parts.each do |part|
				case part
				when StringNode
					push part.unescaped.gsub("`", "\\`")
				else
					visit part
				end
			end
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
			push node.unescaped.gsub("/", '\\/')
			push "/"
			push "i" if node.ignore_case
			push "m" if node.multi_line
			push "x" if node.extended
			push "o" if node.once
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
			visit node.call
			# Targets are written to by the match
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
			visit_each([*node.lefts, node.rest, *node.rights]) { push ", " }
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
			visit node.statements
		end

		visit RangeNode do |node|
			visit node.left
			push node.exclude_end ? "..." : ".."
			visit node.right
		end

		visit RationalNode do |node|
			if node.denominator == 1
				push node.numerator.to_s
				push "r"
			else
				push "#{(node.numerator.to_f / node.denominator)}r"
			end
		end

		visit RedoNode do |node|
			push "redo"
		end

		visit RegularExpressionNode do |node|
			push "/"
			push node.unescaped.gsub("/", '\\/')
			push "/"
			push "i" if node.ignore_case
			push "m" if node.multi_line
			push "x" if node.extended
			push "o" if node.once
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
			visit node.write
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
			push "__LINE__"
		end

		visit SplatNode do |node|
			push "*"
			visit node.expression
		end

		visit StatementsNode do |node|
			visit_each(node.body.flat_map { |n| (Refract::StatementsNode === n) ? n.body : n }) { new_line }
		end

		visit StringNode do |node|
			doubles do
				push node.unescaped.gsub('"', '\"')
			end
		end

		visit SuperNode do |node|
			push "super"
			if node.arguments
				parens do
					visit node.arguments
				end
			end
			visit node.block if node.block
		end

		visit SymbolNode do |node|
			push ":"
			if node.quoted
				doubles do
					push node.unescaped.gsub('"', '\"')
				end
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

		visit UntilNode do |node|
			if node.inline
				visit node.statements
				push " until "
				visit node.predicate
			else
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

		visit XStringNode do |node|
			push "`"
			push node.unescaped
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
	end
end
