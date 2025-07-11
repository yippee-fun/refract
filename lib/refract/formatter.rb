# frozen_string_literal: true

module Refract
	class Formatter
		def initialize
			@buffer = []
			@source_map = []
			@current_line = 1
			@indent = 0
		end

		def self.visit(node_class, &)
			define_method("visit_#{node_class.snake_case_name}", &)
		end

		def format_node(node)
			visit(node)
			@buffer.join
		end

		def visit(node)
			return unless node
			node.accept(self)
		end

		def visit_each(nodes)
			i, len = 0, nodes.length
			if block_given?
				while i < len
					node = nodes[i]
					i += 1
					if node
						visit node
						yield unless i == len
					end
				end
			else
				while i < len
					visit nodes[i]
					i += 1
				end
			end
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

			if node.arguments
				parens { visit node.arguments }
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
			push ":\"#{node.unescaped.gsub('"', '\"')}\""
		end

		visit KeywordHashNode do |node|
			visit_each(node.elements) { push ", " }
		end

		visit AssocNode do |node|
			visit node.key
			push " => "
			visit node.value
		end

		visit ImplicitNode do |node|
			visit node.value
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
					visit node.rescue_clause
				end
			end
		end

		visit RescueNode do |node|
			outdent do
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
	end
end
