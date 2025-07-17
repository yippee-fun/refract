# frozen_string_literal: true

module Refract
	class MutationVisitor < BasicVisitor
		def self.visit(node_class, &)
			define_method("visit_#{node_class.type}") do |node|
				return_value = instance_exec(node, &)
				raise unless node_class === return_value
				return_value
			end
		end

		visit AliasGlobalVariableNode do |node|
			node.update(
				new_name: visit(node.new_name),
				old_name: visit(node.old_name),
			)
		end

		visit AliasMethodNode do |node|
			node.update(
				new_name: visit(node.new_name),
				old_name: visit(node.old_name),
			)
		end

		visit AlternationPatternNode do |node|
			node.update(
				left: visit(node.left),
				right: visit(node.right),
			)
		end

		visit AndNode do |node|
			node.update(
				left: visit(node.left),
				right: visit(node.right),
			)
		end

		visit ArgumentsNode do |node|
			node.update(
				arguments: node.arguments&.map { |n| visit(n) },
			)
		end

		visit ArrayNode do |node|
			node.update(
				elements: node.elements&.map { |n| visit(n) },
			)
		end

		visit ArrayPatternNode do |node|
			node.update(
				constant: visit(node.constant),
				requireds: node.requireds&.map { |n| visit(n) },
				rest: visit(node.rest),
			)
		end

		visit AssocNode do |node|
			node.update(
				key: visit(node.key),
				value: visit(node.value),
			)
		end

		visit AssocSplatNode do |node|
			node.update(
				value: visit(node.value),
			)
		end

		visit BackReferenceReadNode do |node|
			node
		end

		visit BeginNode do |node|
			node.update(
				statements: visit(node.statements),
				rescue_clause: visit(node.rescue_clause),
				else_clause: visit(node.else_clause),
				ensure_clause: visit(node.ensure_clause),
			)
		end

		visit BlockArgumentNode do |node|
			node.update(
				expression: visit(node.expression),
			)
		end

		visit BlockLocalVariableNode do |node|
			node
		end

		visit BlockNode do |node|
			node.update(
				parameters: visit(node.parameters),
				body: visit(node.body),
			)
		end

		visit BlockParameterNode do |node|
			node
		end

		visit BlockParametersNode do |node|
			node.update(
				parameters: visit(node.parameters),
				locals: node.locals&.map { |n| visit(n) },
			)
		end

		visit BreakNode do |node|
			node.update(
				arguments: visit(node.arguments),
			)
		end

		visit CallAndWriteNode do |node|
			node.update(
				receiver: visit(node.receiver),
				value: visit(node.value),
			)
		end

		visit CallNode do |node|
			node.update(
				receiver: visit(node.receiver),
				arguments: visit(node.arguments),
				block: visit(node.block),
			)
		end

		visit CallOperatorWriteNode do |node|
			node.update(
				receiver: visit(node.receiver),
				value: visit(node.value),
			)
		end

		visit CallOrWriteNode do |node|
			node.update(
				receiver: visit(node.receiver),
				value: visit(node.value),
			)
		end

		visit CallTargetNode do |node|
			node.update(
				receiver: visit(node.receiver),
			)
		end

		visit CapturePatternNode do |node|
			node.update(
				value: visit(node.value),
				target: visit(node.target),
			)
		end

		visit CaseMatchNode do |node|
			node.update(
				predicate: visit(node.predicate),
				conditions: node.conditions&.map { |n| visit(n) },
				else_clause: visit(node.else_clause),
			)
		end

		visit CaseNode do |node|
			node.update(
				predicate: visit(node.predicate),
				conditions: node.conditions&.map { |n| visit(n) },
				else_clause: visit(node.else_clause),
			)
		end

		visit ClassNode do |node|
			node.update(
				constant_path: visit(node.constant_path),
				superclass: visit(node.superclass),
				body: visit(node.body),
			)
		end

		visit ClassVariableAndWriteNode do |node|
			node.update(
				value: visit(node.value),
			)
		end

		visit ClassVariableOperatorWriteNode do |node|
			node.update(
				value: visit(node.value),
			)
		end

		visit ClassVariableOrWriteNode do |node|
			node.update(
				value: visit(node.value),
			)
		end

		visit ClassVariableReadNode do |node|
			node
		end

		visit ClassVariableTargetNode do |node|
			node
		end

		visit ClassVariableWriteNode do |node|
			node.update(
				value: visit(node.value),
			)
		end

		visit ConstantOrWriteNode do |node|
			node.update(
				value: visit(node.value),
			)
		end

		visit ConstantPath do |node|
			node.update(
				parent: visit(node.parent),
			)
		end

		visit ConstantPathAndWriteNode do |node|
			node.update(
				target: visit(node.target),
				value: visit(node.value),
			)
		end

		visit ConstantPathOperatorWriteNode do |node|
			node.update(
				target: visit(node.target),
				value: visit(node.value),
			)
		end

		visit ConstantPathOrWriteNode do |node|
			node.update(
				target: visit(node.target),
				value: visit(node.value),
			)
		end

		visit ConstantPathTargetNode do |node|
			node.update(
				parent: visit(node.parent),
			)
		end

		visit ConstantPathWriteNode do |node|
			node.update(
				target: visit(node.target),
				value: visit(node.value),
			)
		end

		visit ConstantReadNode do |node|
			node
		end

		visit ConstantTargetNode do |node|
			node
		end

		visit ConstantWriteNode do |node|
			node.update(
				value: visit(node.value),
			)
		end

		visit DefNode do |node|
			node.update(
				receiver: visit(node.receiver),
				parameters: visit(node.parameters),
				body: visit(node.body),
			)
		end

		visit DefinedNode do |node|
			node.update(
				value: visit(node.value),
			)
		end

		visit ElseNode do |node|
			node.update(
				statements: visit(node.statements),
			)
		end

		visit EmbeddedStatementsNode do |node|
			node.update(
				statements: visit(node.statements),
			)
		end

		visit EmbeddedVariableNode do |node|
			node.update(
				variable: visit(node.variable),
			)
		end

		visit EnsureNode do |node|
			node.update(
				statements: visit(node.statements),
			)
		end

		visit FalseNode do |node|
			node
		end

		visit FindPatternNode do |node|
			node.update(
				constant: visit(node.constant),
				left: visit(node.left),
				requireds: node.requireds&.map { |n| visit(n) },
				right: visit(node.right),
			)
		end

		visit FlipFlopNode do |node|
			node.update(
				left: visit(node.left),
				right: visit(node.right),
			)
		end

		visit FloatNode do |node|
			node
		end

		visit ForNode do |node|
			node.update(
				index: visit(node.index),
				collection: visit(node.collection),
				statements: visit(node.statements),
			)
		end

		visit ForwardingArgumentsNode do |node|
			node
		end

		visit ForwardingParameterNode do |node|
			node
		end

		visit ForwardingSuperNode do |node|
			node.update(
				block: visit(node.block),
			)
		end

		visit GlobalVariableAndWriteNode do |node|
			node.update(
				value: visit(node.value),
			)
		end

		visit GlobalVariableOperatorWriteNode do |node|
			node.update(
				value: visit(node.value),
			)
		end

		visit GlobalVariableOrWriteNode do |node|
			node.update(
				value: visit(node.value),
			)
		end

		visit GlobalVariableReadNode do |node|
			node
		end

		visit GlobalVariableTargetNode do |node|
			node
		end

		visit GlobalVariableWriteNode do |node|
			node.update(
				value: visit(node.value),
			)
		end

		visit HashNode do |node|
			node.update(
				elements: node.elements&.map { |n| visit(n) },
			)
		end

		visit HashPatternNode do |node|
			node.update(
				elements: node.elements&.map { |n| visit(n) },
				rest: visit(node.rest),
			)
		end

		visit IfNode do |node|
			node.update(
				predicate: visit(node.predicate),
				statements: visit(node.statements),
				subsequent: visit(node.subsequent),
			)
		end

		visit ImaginaryNode do |node|
			node.update(
				numeric: visit(node.numeric),
			)
		end

		visit ImplicitNode do |node|
			node
		end

		visit ImplicitRestNode do |node|
			node
		end

		visit InNode do |node|
			node.update(
				pattern: visit(node.pattern),
				statements: visit(node.statements),
			)
		end

		visit IndexAndWriteNode do |node|
			node.update(
				receiver: visit(node.receiver),
				arguments: visit(node.arguments),
				block: visit(node.block),
				value: visit(node.value),
			)
		end

		visit IndexOperatorWriteNode do |node|
			node.update(
				receiver: visit(node.receiver),
				arguments: visit(node.arguments),
				block: visit(node.block),
				value: visit(node.value),
			)
		end

		visit InstanceVariableAndWriteNode do |node|
			node.update(
				value: visit(node.value),
			)
		end

		visit InstanceVariableOperatorWriteNode do |node|
			node.update(
				value: visit(node.value),
			)
		end

		visit InstanceVariableOrWriteNode do |node|
			node.update(
				value: visit(node.value),
			)
		end

		visit InstanceVariableReadNode do |node|
			node
		end

		visit InstanceVariableTargetNode do |node|
			node
		end

		visit InstanceVariableWriteNode do |node|
			node.update(
				value: visit(node.value),
			)
		end

		visit IntegerNode do |node|
			node
		end

		visit InterpolatedRegularExpressionNode do |node|
			node.update(
				parts: node.parts&.map { |n| visit(n) },
			)
		end

		visit InterpolatedStringNode do |node|
			node.update(
				parts: node.parts&.map { |n| visit(n) },
			)
		end

		visit InterpolatedSymbolNode do |node|
			node.update(
				parts: node.parts&.map { |n| visit(n) },
			)
		end

		visit InterpolatedXStringNode do |node|
			node.update(
				parts: node.parts&.map { |n| visit(n) },
			)
		end

		visit ItLocalVariableReadNode do |node|
			node
		end

		visit ItParametersNode do |node|
			node
		end

		visit KeywordHashNode do |node|
			node.update(
				elements: node.elements&.map { |n| visit(n) },
			)
		end

		visit KeywordRestParameterNode do |node|
			node
		end

		visit LambdaNode do |node|
			node.update(
				parameters: visit(node.parameters),
				body: visit(node.body),
			)
		end

		visit LocalVariableAndWriteNode do |node|
			node.update(
				value: visit(node.value),
			)
		end

		visit LocalVariableOperatorWriteNode do |node|
			node.update(
				value: visit(node.value),
			)
		end

		visit LocalVariableOrWriteNode do |node|
			node.update(
				value: visit(node.value),
			)
		end

		visit LocalVariableReadNode do |node|
			node
		end

		visit LocalVariableTargetNode do |node|
			node
		end

		visit LocalVariableWriteNode do |node|
			node.update(
				value: visit(node.value),
			)
		end

		visit MatchLastLineNode do |node|
			node
		end

		visit MatchPredicateNode do |node|
			node.update(
				value: visit(node.value),
				pattern: visit(node.pattern),
			)
		end

		visit MatchRequiredNode do |node|
			node.update(
				value: visit(node.value),
				pattern: visit(node.pattern),
			)
		end

		visit MatchWriteNode do |node|
			node.update(
				call: visit(node.call),
				targets: node.targets&.map { |n| visit(n) },
			)
		end

		visit MissingNode do |node|
			node
		end

		visit ModuleNode do |node|
			node.update(
				constant_path: visit(node.constant_path),
				body: visit(node.body),
			)
		end

		visit MultiTargetNode do |node|
			node.update(
				lefts: node.lefts&.map { |n| visit(n) },
				rest: visit(node.rest),
				rights: node.rights&.map { |n| visit(n) },
			)
		end

		visit MultiWriteNode do |node|
			node.update(
				lefts: node.lefts&.map { |n| visit(n) },
				rest: visit(node.rest),
				rights: node.rights&.map { |n| visit(n) },
				value: visit(node.value),
			)
		end

		visit NextNode do |node|
			node.update(
				arguments: visit(node.arguments),
			)
		end

		visit NilNode do |node|
			node
		end

		visit NumberedReferenceReadNode do |node|
			node
		end

		visit OptionalKeywordParameterNode do |node|
			node.update(
				value: visit(node.value),
			)
		end

		visit OptionalParameterNode do |node|
			node.update(
				value: visit(node.value),
			)
		end

		visit OrNode do |node|
			node.update(
				left: visit(node.left),
				right: visit(node.right),
			)
		end

		visit ParametersNode do |node|
			node.update(
				requireds: node.requireds&.map { |n| visit(n) },
				optionals: node.optionals&.map { |n| visit(n) },
				rest: visit(node.rest),
				posts: node.posts&.map { |n| visit(n) },
				keywords: node.keywords&.map { |n| visit(n) },
				keyword_rest: visit(node.keyword_rest),
				block: visit(node.block),
			)
		end

		visit ParenthesesNode do |node|
			node.update(
				body: visit(node.body),
			)
		end

		visit RangeNode do |node|
			node.update(
				left: visit(node.left),
				right: visit(node.right),
			)
		end

		visit RationalNode do |node|
			node
		end

		visit RedoNode do |node|
			node
		end

		# visit ProgramNode do |node|
		# 	visit(node.statements)
		# end

		visit RegularExpressionNode do |node|
			node
		end

		visit RequiredKeywordParameterNode do |node|
			node
		end

		visit RequiredParameterNode do |node|
			node
		end

		visit RescueModifierNode do |node|
			node.update(
				expression: visit(node.expression),
				rescue_expression: visit(node.rescue_expression),
			)
		end

		visit RescueNode do |node|
			node.update(
				exceptions: node.exceptions&.map { |n| visit(n) },
				reference: visit(node.reference),
				statements: visit(node.statements),
				subsequent: visit(node.subsequent),
			)
		end

		visit RestParameterNode do |node|
			node
		end

		visit RetryNode do |node|
			node
		end

		visit ReturnNode do |node|
			node.update(
				arguments: visit(node.arguments),
			)
		end

		visit SelfNode do |node|
			node
		end

		visit ShareableConstantNode do |node|
			node.update(
				write: visit(node.write),
			)
		end

		visit SingletonClassNode do |node|
			node.update(
				expression: visit(node.expression),
				body: visit(node.body),
			)
		end

		visit SourceEncodingNode do |node|
			node
		end

		visit SourceFileNode do |node|
			node
		end

		visit SourceLineNode do |node|
			node
		end

		visit SplatNode do |node|
			node.update(
				expression: visit(node.expression),
			)
		end

		visit StatementsNode do |node|
			node.update(
				body: node.body&.map { |n| visit(n) },
			)
		end

		visit StringNode do |node|
			node
		end

		visit SuperNode do |node|
			node.update(
				arguments: visit(node.arguments),
				block: visit(node.block),
			)
		end

		visit SymbolNode do |node|
			node
		end

		visit TrueNode do |node|
			node
		end

		visit UndefNode do |node|
			node.update(
				names: node.names&.map { |n| visit(n) },
			)
		end

		visit UnlessNode do |node|
			node.update(
				predicate: visit(node.predicate),
				statements: visit(node.statements),
				else_clause: visit(node.else_clause),
			)
		end

		visit UntilNode do |node|
			node.update(
				predicate: visit(node.predicate),
				statements: visit(node.statements),
			)
		end

		visit WhenNode do |node|
			node.update(
				conditions: node.conditions&.map { |n| visit(n) },
				statements: visit(node.statements),
			)
		end

		visit WhileNode do |node|
			node.update(
				predicate: visit(node.predicate),
				statements: visit(node.statements),
			)
		end

		visit XStringNode do |node|
			node
		end

		visit YieldNode do |node|
			node.update(
				arguments: visit(node.arguments),
			)
		end
	end
end
