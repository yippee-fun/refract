# frozen_string_literal: true

module Refract
	class Visitor < BasicVisitor
		visit AliasGlobalVariableNode do |node|
			visit node.new_name
			visit node.old_name
		end

		visit AliasMethodNode do |node|
			visit node.new_name
			visit node.old_name
		end

		visit AlternationPatternNode do |node|
			visit node.left
			visit node.right
		end

		visit AndNode do |node|
			visit node.left
			visit node.right
		end

		visit ArgumentsNode do |node|
			visit_each node.arguments
		end

		visit ArrayNode do |node|
			visit_each node.elements
		end

		visit ArrayPatternNode do |node|
			visit node.constant
			visit_each node.requireds
			visit node.rest
		end

		visit AssocNode do |node|
			visit node.key
			visit node.value
		end

		visit AssocSplatNode do |node|
			visit node.value
		end

		visit BackReferenceReadNode do |node|
			nil
		end

		visit BeginNode do |node|
			visit node.statements
			visit node.rescue_clause
			visit node.else_clause
			visit node.ensure_clause
		end

		visit BlockArgumentNode do |node|
			visit node.expression
		end

		visit BlockLocalVariableNode do |node|
			nil
		end

		visit BlockNode do |node|
			visit node.parameters
			visit node.body
		end

		visit BlockParameterNode do |node|
			nil
		end

		visit BlockParametersNode do |node|
			visit node.parameters
			visit_each node.locals
		end

		visit BreakNode do |node|
			visit node.arguments
		end

		visit CallAndWriteNode do |node|
			visit node.receiver
			visit node.value
		end

		visit CallNode do |node|
			visit node.receiver
			visit node.arguments
			visit node.block
		end

		visit CallOperatorWriteNode do |node|
			visit node.receiver
			visit node.value
		end

		visit CallOrWriteNode do |node|
			visit node.receiver
			visit node.value
		end

		visit CallTargetNode do |node|
			visit node.receiver
		end

		visit CapturePatternNode do |node|
			visit node.value
			visit node.target
		end

		visit CaseMatchNode do |node|
			visit node.predicate
			visit_each node.conditions
			visit node.else_clause
		end

		visit CaseNode do |node|
			visit node.predicate
			visit_each node.conditions
			visit node.else_clause
		end

		visit ClassNode do |node|
			visit node.constant_path
			visit node.superclass
			visit node.body
		end

		visit ClassVariableAndWriteNode do |node|
			visit node.value
		end

		visit ClassVariableOperatorWriteNode do |node|
			visit node.value
		end

		visit ClassVariableOrWriteNode do |node|
			visit node.value
		end

		visit ClassVariableReadNode do |node|
			push node.name
		end

		visit ClassVariableTargetNode do |node|
			push node.name
		end

		visit ClassVariableWriteNode do |node|
			visit node.value
		end

		visit ConstantAndWriteNode do |node|
			visit node.value
		end

		visit ConstantOperatorWriteNode do |node|
			visit node.value
		end

		visit ConstantOrWriteNode do |node|
			visit node.value
		end

		visit ConstantPath do |node|
			visit node.parent
		end

		visit ConstantPathAndWriteNode do |node|
			visit node.target
			visit node.value
		end

		visit ConstantPathOperatorWriteNode do |node|
			visit node.target
			visit node.value
		end

		visit ConstantPathOrWriteNode do |node|
			visit node.target
			visit node.value
		end

		visit ConstantPathTargetNode do |node|
			visit node.parent
		end

		visit ConstantPathWriteNode do |node|
			visit node.target
			visit node.value
		end

		visit ConstantReadNode do |node|
			nil
		end

		visit ConstantTargetNode do |node|
			nil
		end

		visit ConstantWriteNode do |node|
			visit node.value
		end

		visit DefNode do |node|
			visit node.receiver
			visit node.parameters
			visit node.body
		end

		visit DefinedNode do |node|
			visit node.value
		end

		visit ElseNode do |node|
			visit node.statements
		end

		visit EmbeddedStatementsNode do |node|
			visit node.statements
		end

		visit EmbeddedVariableNode do |node|
			visit node.variable
		end

		visit EnsureNode do |node|
			visit node.statements
		end

		visit FalseNode do |node|
			nil
		end

		visit FindPatternNode do |node|
			visit node.constant
			visit node.left
			visit_each node.requireds
			visit node.right
		end

		visit FlipFlopNode do |node|
			visit node.left
			visit node.right
		end

		visit FloatNode do |node|
			nil
		end

		visit ForNode do |node|
			visit node.index
			visit node.collection
			visit node.statements
		end

		visit ForwardingArgumentsNode do |node|
			nil
		end

		visit ForwardingParameterNode do |node|
			nil
		end

		visit ForwardingSuperNode do |node|
			visit node.block
		end

		visit GlobalVariableAndWriteNode do |node|
			visit node.value
		end

		visit GlobalVariableOperatorWriteNode do |node|
			visit node.value
		end

		visit GlobalVariableOrWriteNode do |node|
			visit node.value
		end

		visit GlobalVariableReadNode do |node|
			nil
		end

		visit GlobalVariableTargetNode do |node|
			nil
		end

		visit GlobalVariableWriteNode do |node|
			visit node.value
		end

		visit HashNode do |node|
			visit_each node.elements
		end

		visit HashPatternNode do |node|
			visit_each node.elements
			visit node.rest
		end

		visit IfNode do |node|
			visit node.predicate
			visit node.statements
			visit node.subsequent
		end

		visit ImaginaryNode do |node|
			visit node.numeric
		end

		visit ImplicitNode do |node|
			nil
		end

		visit ImplicitRestNode do |node|
			nil
		end

		visit InNode do |node|
			visit node.pattern
			visit node.statements
		end

		visit IndexAndWriteNode do |node|
			visit node.receiver
			visit node.arguments
			visit node.block
			visit node.value
		end

		visit IndexOperatorWriteNode do |node|
			visit node.receiver
			visit node.arguments
			visit node.block
			visit node.value
		end

		visit IndexOrWriteNode do |node|
			visit node.receiver
			visit node.arguments
			visit node.block
			visit node.value
		end

		visit IndexTargetNode do |node|
			visit node.receiver
			visit node.arguments
			visit node.block
		end

		visit InstanceVariableAndWriteNode do |node|
			visit node.value
		end

		visit InstanceVariableOperatorWriteNode do |node|
			visit node.value
		end

		visit InstanceVariableOrWriteNode do |node|
			visit node.value
		end

		visit InstanceVariableReadNode do |node|
			nil
		end

		visit InstanceVariableTargetNode do |node|
			nil
		end

		visit InstanceVariableWriteNode do |node|
			visit node.value
		end

		visit IntegerNode do |node|
			nil
		end

		visit InterpolatedRegularExpressionNode do |node|
			visit_each node.parts
		end

		visit InterpolatedStringNode do |node|
			visit_each node.parts
		end

		visit InterpolatedSymbolNode do |node|
			visit_each node.parts
		end

		visit InterpolatedXStringNode do |node|
			visit_each node.parts
		end

		visit ItLocalVariableReadNode do |node|
			nil
		end

		visit ItParametersNode do |node|
			nil
		end

		visit KeywordHashNode do |node|
			visit_each node.elements
		end

		visit KeywordRestParameterNode do |node|
			nil
		end

		visit LambdaNode do |node|
			visit node.parameters
			visit node.body
		end

		visit LocalVariableAndWriteNode do |node|
			visit node.value
		end

		visit LocalVariableOperatorWriteNode do |node|
			visit node.value
		end

		visit LocalVariableOrWriteNode do |node|
			visit node.value
		end

		visit LocalVariableReadNode do |node|
			nil
		end

		visit LocalVariableTargetNode do |node|
			nil
		end

		visit LocalVariableWriteNode do |node|
			visit node.value
		end

		visit MatchLastLineNode do |node|
			nil
		end

		visit MatchPredicateNode do |node|
			visit node.value
			visit node.pattern
		end

		visit MatchRequiredNode do |node|
			visit node.value
			visit node.pattern
		end

		visit MatchWriteNode do |node|
			visit node.call
			visit_each node.targets
		end

		visit MissingNode do |node|
			nil
		end

		visit ModuleNode do |node|
			visit node.constant_path
			visit node.body
		end

		visit MultiTargetNode do |node|
			visit_each node.lefts
			visit node.rest
			visit_each node.rights
		end

		visit MultiWriteNode do |node|
			visit_each node.lefts
			visit node.rest
			visit_each node.rights
			visit node.value
		end

		visit NextNode do |node|
			visit node.arguments
		end

		visit NilNode do |node|
			nil
		end

		visit NumberedReferenceReadNode do |node|
			nil
		end

		visit OptionalKeywordParameterNode do |node|
			visit node.value
		end

		visit OptionalParameterNode do |node|
			visit node.value
		end

		visit OrNode do |node|
			visit node.left
			visit node.right
		end

		visit ParametersNode do |node|
			visit_each node.requireds
			visit_each node.optionals
			visit      node.rest
			visit_each node.posts
			visit_each node.keywords
			visit      node.keyword_rest
			visit      node.block
		end

		visit ParenthesesNode do |node|
			visit node.body
		end

		visit RangeNode do |node|
			visit node.left
			visit node.right
		end

		visit RationalNode do |node|
			nil
		end

		visit RedoNode do |node|
			nil
		end

		# visit ProgramNode do |node|
		# 	visit(node.statements)
		# end

		visit RegularExpressionNode do |node|
			nil
		end

		visit RequiredKeywordParameterNode do |node|
			nil
		end

		visit RequiredParameterNode do |node|
			nil
		end

		visit RescueModifierNode do |node|
			visit node.expression
			visit node.rescue_expression
		end

		visit RescueNode do |node|
			visit_each node.exceptions
			visit node.reference
			visit node.statements
			visit node.subsequent
		end

		visit RestParameterNode do |node|
			nil
		end

		visit RetryNode do |node|
			nil
		end

		visit ReturnNode do |node|
			visit node.arguments
		end

		visit SelfNode do |node|
			nil
		end

		visit ShareableConstantNode do |node|
			visit node.write
		end

		visit SingletonClassNode do |node|
			visit node.expression
			visit node.body
		end

		visit SourceEncodingNode do |node|
			nil
		end

		visit SourceFileNode do |node|
			nil
		end

		visit SourceLineNode do |node|
			nil
		end

		visit SplatNode do |node|
			visit node.expression
		end

		visit StatementsNode do |node|
			visit_each node.body
		end

		visit StringNode do |node|
			nil
		end

		visit SuperNode do |node|
			visit node.arguments
			visit node.block
		end

		visit SymbolNode do |node|
			nil
		end

		visit TrueNode do |node|
			nil
		end

		visit UndefNode do |node|
			visit_each node.names
		end

		visit UnlessNode do |node|
			visit node.predicate
			visit node.statements
			visit node.else_clause
		end

		visit UntilNode do |node|
			visit node.predicate
			visit node.statements
		end

		visit WhenNode do |node|
			visit_each node.conditions
			visit node.statements
		end

		visit WhileNode do |node|
			visit node.predicate
			visit node.statements
		end

		visit XStringNode do |node|
			nil
		end

		visit YieldNode do |node|
			visit node.arguments
		end
	end
end
