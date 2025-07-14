# frozen_string_literal: true

module Refract
	class Formatter < BasicVisitor
		def initialize
			super
			@buffer = []
			@source_map = []
			@current_line = 1
			@indent = 0
		end

		def format_node(node)
			visit(node)
			@buffer.join
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

		visit CallNode do |node|
			if node.receiver
				visit node.receiver
				push "."
			end

			push node.message

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

		visit GlobalVariableReadNode do |node|
			push node.name
		end

		visit LocalVariableTargetNode do |node|
			push node.name
		end

		visit MatchRequiredNode do |node|
			visit node.value
			space
			push "=>"
			space
			visit node.pattern
		end

		# visit ProgramNode do |node|
		# 	visit(node.statements)
		# end

		visit StatementsNode do |node|
			visit_each(node.body) { new_line }
		end

		visit SymbolNode do |node|
			push ":"
			push node.unescaped
		end

		visit KeywordHashNode do |node|
			visit_each(node.elements) { push ", " }
		end

		visit AssocNode do |node|
			case node.key
			when SymbolNode
				push node.key.unescaped
				push ":"
				space unless ImplicitNode === node.value
				visit node.value
			else
				visit node.key
				push " => "
				visit node.value
			end
		end

		visit ImplicitNode do |node|
			nil
		end

		visit ArrayNode do |node|
			brackets do
				indent do
					visit_each(node.elements) { push ","; new_line }
				end

				new_line
			end
		end

		visit IntegerNode do |node|
			push node.value.to_s
		end

		visit MatchPredicateNode do |node|
			visit node.value
			push " in "
			visit node.pattern
		end

		visit ArrayPatternNode do |node|
			visit node.constant
			brackets do
				visit_each(node.requireds) { push ", " }
				visit(node.rest)
			end
		end

		visit SplatNode do |node|
			push "*"
			visit node.expression
		end

		visit ConstantReadNode do |node|
			push node.name
		end

		visit HashNode do |node|
			braces do
				indent do
					visit_each(node.elements) { push ","; new_line }
				end

				new_line
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

		visit EnsureNode do |node|
			push "ensure"

			indent do
				visit node.statements
			end
		end

		visit RescueNode do |node|
			push "rescue"
			space
			visit_each(node.exceptions) { push ", " }

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

		visit ElseNode do |node|
			push "else"

			indent do
				visit node.statements
			end
		end

		visit BlockNode do |node|
			braces do
				if node.parameters
					space
					visit node.parameters
				end

				indent do
					visit node.body
				end

				new_line
			end
		end

		visit BlockParametersNode do |node|
			pipes do
				visit node.parameters

				if node.locals&.any?
					push "; "
					visit_each(node.locals) { push ", " }
				end
			end
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

		visit RequiredKeywordParameterNode do |node|
			push node.name
			push ":"
		end

		visit RequiredParameterNode do |node|
			push node.name
		end

		visit BlockLocalVariableNode do |node|
			push node.name
		end

		visit BlockArgumentNode do |node|
			push "&"
			visit node.expression
		end

		visit StringNode do |node|
			push '"'
			push node.unescaped.gsub('"', '\\"')
			push '"'
		end

		visit LocalVariableReadNode do |node|
			push node.name
		end

		visit OptionalParameterNode do |node|
			push node.name
			push " = "
			visit node.value
		end

		visit OptionalKeywordParameterNode do |node|
			push node.name
			push ": "
			visit node.value
		end

		visit BlockParameterNode do |node|
			push "&"
			push node.name
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

		visit RestParameterNode do |node|
			push "*"
			push node.name
		end

		visit KeywordRestParameterNode do |node|
			push "**"
			push node.name
		end

		visit ForwardingParameterNode do |node|
			push "..."
		end

		visit NilNode do |node|
			push "nil"
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

		visit MultiWriteNode do |node|
			visit_each([*node.lefts, node.rest, *node.rights]) { push ", " }
			space unless ImplicitRestNode === node.rest
			push "= "
			visit node.value
		end

		visit CallTargetNode do |node|
			if node.receiver
				visit node.receiver
				push "."
			end

			push node.name[0..-2]
		end

		visit ImplicitRestNode do |node|
			nil
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

		visit TrueNode do |node|
			push "true"
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

		visit FalseNode do |node|
			push "false"
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

		visit WhenNode do |node|
			push "when"
			space
			visit_each(node.conditions) { push ", " }
			indent do
				visit node.statements
			end
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

		visit ConstantPath do |node|
			visit node.parent
			push "::"
			push node.name
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
			push "\n#{"\t" * @indent}"
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
	end
end
