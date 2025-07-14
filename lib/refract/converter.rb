# frozen_string_literal: true

module Refract
	class Converter < Prism::BasicVisitor
		def self.visit(node_class, &)
			raise ArgumentError unless Class === node_class && Prism::Node > node_class
			type = node_class.type.name

			define_method("visit_#{type}") do |node|
				raise ArgumentError unless node_class === node
				return_value = instance_exec(node, &)
				raise ArgumentError unless NodeInstance === return_value
				return_value
			end
		end

		visit Prism::AliasGlobalVariableNode do |node|
			AliasGlobalVariableNode.new(
				new_name: visit(node.new_name),
				old_name: visit(node.old_name),
			)
		end

		visit Prism::AliasMethodNode do |node|
			AliasMethodNode.new(
				new_name: visit(node.new_name),
				old_name: visit(node.old_name),
			)
		end

		visit Prism::AlternationPatternNode do |node|
			AlternationPatternNode.new(
				left: visit(node.left),
				right: visit(node.right),
			)
		end

		visit Prism::AndNode do |node|
			AndNode.new(
				left: visit(node.left),
				operator: node.operator_loc.slice,
				right: visit(node.right),
			)
		end

		visit Prism::ArgumentsNode do |node|
			ArgumentsNode.new(
				arguments: node.arguments&.map { |n| visit(n) }
			)
		end

		visit Prism::ArrayNode do |node|
			ArrayNode.new(
				elements: node.elements&.map { |n| visit(n) }
			)
		end

		visit Prism::ArrayPatternNode do |node|
			ArrayPatternNode.new(
				constant: visit(node.constant),
				requireds: node.requireds&.map { |n| visit(n) },
				rest: visit(node.rest),
				posts: node.posts&.map { |n| visit(n) },
			)
		end

		visit Prism::AssocNode do |node|
			AssocNode.new(
				key: visit(node.key),
				value: visit(node.value),
			)
		end

		visit Prism::AssocSplatNode do |node|
			AssocSplatNode.new(
				value: visit(node.value)
			)
		end

		visit Prism::BackReferenceReadNode do |node|
			BackReferenceReadNode.new(
				name: node.name
			)
		end

		visit Prism::BeginNode do |node|
			BeginNode.new(
				statements: visit(node.statements),
				rescue_clause: visit(node.rescue_clause),
				else_clause: visit(node.else_clause),
				ensure_clause: visit(node.ensure_clause),
			)
		end

		visit Prism::BlockArgumentNode do |node|
			BlockArgumentNode.new(
				expression: visit(node.expression)
			)
		end

		visit Prism::BlockLocalVariableNode do |node|
			BlockLocalVariableNode.new(
				name: node.name
			)
		end

		visit Prism::BlockNode do |node|
			BlockNode.new(
				parameters: visit(node.parameters),
				body: visit(node.body)
			)
		end

		visit Prism::BlockParameterNode do |node|
			BlockParameterNode.new(
				name: node.name
			)
		end

		visit Prism::BlockParametersNode do |node|
			BlockParametersNode.new(
				parameters: visit(node.parameters),
				locals: node.locals&.map { |n| visit(n) }
			)
		end

		visit Prism::BreakNode do |node|
			BreakNode.new(
				arguments: visit(node.arguments)
			)
		end

		visit Prism::CallAndWriteNode do |node|
			CallAndWriteNode.new(
				receiver: visit(node.receiver),
				read_name: node.read_name,
				value: visit(node.value)
			)
		end

		visit Prism::CallNode do |node|
			CallNode.new(
				receiver: visit(node.receiver),
				message: node.message,
				arguments: visit(node.arguments),
				block: visit(node.block),
			)
		end

		visit Prism::CallOperatorWriteNode do |node|
			CallOperatorWriteNode.new(
				receiver: visit(node.receiver),
				read_name: node.read_name,
				binary_operator: node.binary_operator,
				value: visit(node.value),
			)
		end

		visit Prism::CallOrWriteNode do |node|
			CallOrWriteNode.new(
				receiver: visit(node.receiver),
				read_name: node.read_name,
				value: visit(node.value),
			)
		end

		visit Prism::CallTargetNode do |node|
			CallTargetNode.new(
				receiver: visit(node.receiver),
				name: node.name,
			)
		end

		visit Prism::CapturePatternNode do |node|
			CapturePatternNode.new(
				value: visit(node.value),
				target: visit(node.target),
			)
		end

		visit Prism::CaseMatchNode do |node|
			CaseMatchNode.new(
				predicate: visit(node.predicate),
				conditions: node.conditions&.map { |n| visit(n) },
				else_clause: visit(node.else_clause),
			)
		end

		visit Prism::CaseNode do |node|
			CaseNode.new(
				predicate: visit(node.predicate),
				conditions: node.conditions&.map { |n| visit(n) },
				else_clause: visit(node.else_clause),
			)
		end

		visit Prism::ClassNode do |node|
			ClassNode.new(
				constant_path: visit(node.constant_path),
				superclass: visit(node.superclass),
				body: visit(node.body),
			)
		end

		visit Prism::ClassVariableAndWriteNode do |node|
			ClassVariableAndWriteNode.new(
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::ClassVariableOperatorWriteNode do |node|
			ClassVariableOperatorWriteNode.new(
				name: node.name,
				value: visit(node.value),
				binary_operator: node.binary_operator,
			)
		end

		visit Prism::ClassVariableOrWriteNode do |node|
			ClassVariableOrWriteNode.new(
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::ClassVariableReadNode do |node|
			binding.irb
		end

		visit Prism::ClassVariableTargetNode do |node|
			binding.irb
		end

		visit Prism::ClassVariableWriteNode do |node|
			binding.irb
		end

		visit Prism::ConstantAndWriteNode do |node|
			binding.irb
		end

		visit Prism::ConstantOperatorWriteNode do |node|
			binding.irb
		end

		visit Prism::ConstantOrWriteNode do |node|
			binding.irb
		end

		visit Prism::ConstantPathAndWriteNode do |node|
			binding.irb
		end

		visit Prism::ConstantPathNode do |node|
			ConstantPath.new(
				parent: visit(node.parent),
				name: node.name,
			)
		end

		visit Prism::ConstantPathOperatorWriteNode do |node|
			binding.irb
		end

		visit Prism::ConstantPathOrWriteNode do |node|
			binding.irb
		end

		visit Prism::ConstantPathTargetNode do |node|
			binding.irb
		end

		visit Prism::ConstantPathWriteNode do |node|
			binding.irb
		end

		visit Prism::ConstantReadNode do |node|
			ConstantReadNode.new(
					name: node.name
				)
		end

		visit Prism::ConstantTargetNode do |node|
			binding.irb
		end

		visit Prism::ConstantWriteNode do |node|
			binding.irb
		end

		visit Prism::DefNode do |node|
			DefNode.new(
				name: node.name,
				receiver: visit(node.receiver),
				parameters: visit(node.parameters),
				body: visit(node.body),
			)
		end

		visit Prism::DefinedNode do |node|
			binding.irb
		end

		visit Prism::ElseNode do |node|
			ElseNode.new(
				statements: visit(node.statements)
			)
		end

		visit Prism::EmbeddedStatementsNode do |node|
			binding.irb
		end

		visit Prism::EmbeddedVariableNode do |node|
			binding.irb
		end

		visit Prism::EnsureNode do |node|
			EnsureNode.new(
				statements: visit(node.statements)
			)
		end

		visit Prism::FalseNode do |node|
			FalseNode.new
		end

		visit Prism::FindPatternNode do |node|
			binding.irb
		end

		visit Prism::FlipFlopNode do |node|
			binding.irb
		end

		visit Prism::FloatNode do |node|
			binding.irb
		end

		visit Prism::ForNode do |node|
			binding.irb
		end

		visit Prism::ForwardingArgumentsNode do |node|
			binding.irb
		end

		visit Prism::ForwardingParameterNode do |node|
			ForwardingParameterNode.new
		end

		visit Prism::ForwardingSuperNode do |node|
			binding.irb
		end

		visit Prism::GlobalVariableAndWriteNode do |node|
			binding.irb
		end

		visit Prism::GlobalVariableOperatorWriteNode do |node|
			binding.irb
		end

		visit Prism::GlobalVariableOrWriteNode do |node|
			binding.irb
		end

		visit Prism::GlobalVariableReadNode do |node|
			GlobalVariableReadNode.new(
				name: node.name
			)
		end

		visit Prism::GlobalVariableTargetNode do |node|
			binding.irb
		end

		visit Prism::GlobalVariableWriteNode do |node|
			binding.irb
		end

		visit Prism::HashNode do |node|
			HashNode.new(
				elements: node.elements&.map { |n| visit(n) }
			)
		end

		visit Prism::HashPatternNode do |node|
			binding.irb
		end

		visit Prism::IfNode do |node|
			binding.irb
		end

		visit Prism::ImaginaryNode do |node|
			binding.irb
		end

		visit Prism::ImplicitNode do |node|
			ImplicitNode.new(
				value: visit(node.value)
			)
		end

		visit Prism::ImplicitRestNode do |node|
			ImplicitRestNode.new
		end

		visit Prism::InNode do |node|
			InNode.new(
				pattern: visit(node.pattern),
				statements: visit(node.statements),
			)
		end

		visit Prism::IndexAndWriteNode do |node|
			binding.irb
		end

		visit Prism::IndexOperatorWriteNode do |node|
			binding.irb
		end

		visit Prism::IndexOrWriteNode do |node|
			binding.irb
		end

		visit Prism::IndexTargetNode do |node|
			binding.irb
		end

		visit Prism::InstanceVariableAndWriteNode do |node|
			binding.irb
		end

		visit Prism::InstanceVariableOperatorWriteNode do |node|
			binding.irb
		end

		visit Prism::InstanceVariableOrWriteNode do |node|
			binding.irb
		end

		visit Prism::InstanceVariableReadNode do |node|
			binding.irb
		end

		visit Prism::InstanceVariableTargetNode do |node|
			binding.irb
		end

		visit Prism::InstanceVariableWriteNode do |node|
			binding.irb
		end

		visit Prism::IntegerNode do |node|
			IntegerNode.new(
				value: node.value
			)
		end

		visit Prism::InterpolatedMatchLastLineNode do |node|
			binding.irb
		end

		visit Prism::InterpolatedRegularExpressionNode do |node|
			binding.irb
		end

		visit Prism::InterpolatedStringNode do |node|
			binding.irb
		end

		visit Prism::InterpolatedSymbolNode do |node|
			binding.irb
		end

		visit Prism::InterpolatedXStringNode do |node|
			binding.irb
		end

		visit Prism::ItLocalVariableReadNode do |node|
			binding.irb
		end

		visit Prism::ItParametersNode do |node|
			binding.irb
		end

		visit Prism::KeywordHashNode do |node|
			KeywordHashNode.new(
				elements: node.elements&.map { |n| visit(n) }
			)
		end

		visit Prism::KeywordRestParameterNode do |node|
			KeywordRestParameterNode.new(
				name: node.name
			)
		end

		visit Prism::LambdaNode do |node|
			binding.irb
		end

		visit Prism::LocalVariableAndWriteNode do |node|
			binding.irb
		end

		visit Prism::LocalVariableOperatorWriteNode do |node|
			binding.irb
		end

		visit Prism::LocalVariableOrWriteNode do |node|
			binding.irb
		end

		visit Prism::LocalVariableReadNode do |node|
			LocalVariableReadNode.new(
				name: node.name
			)
		end

		visit Prism::LocalVariableTargetNode do |node|
			LocalVariableTargetNode.new(
				name: node.name
			)
		end

		visit Prism::LocalVariableWriteNode do |node|
			binding.irb
		end

		visit Prism::MatchLastLineNode do |node|
			binding.irb
		end

		visit Prism::MatchPredicateNode do |node|
			MatchPredicateNode.new(
				value: visit(node.value),
				pattern: visit(node.pattern),
			)
		end

		visit Prism::MatchRequiredNode do |node|
			MatchRequiredNode.new(
				value: visit(node.value),
				pattern: visit(node.pattern),
			)
		end

		visit Prism::MatchWriteNode do |node|
			binding.irb
		end

		visit Prism::MissingNode do |node|
			binding.irb
		end

		visit Prism::ModuleNode do |node|
			binding.irb
		end

		visit Prism::MultiTargetNode do |node|
			binding.irb
		end

		visit Prism::MultiWriteNode do |node|
			MultiWriteNode.new(
				lefts: node.lefts&.map { |n| visit(n) },
				rest: visit(node.rest),
				rights: node.rights&.map { |n| visit(n) },
				value: visit(node.value),
			)
		end

		visit Prism::NextNode do |node|
			binding.irb
		end

		visit Prism::NilNode do |node|
			NilNode.new
		end

		visit Prism::NoKeywordsParameterNode do |node|
			binding.irb
		end

		visit Prism::NumberedParametersNode do |node|
			binding.irb
		end

		visit Prism::NumberedReferenceReadNode do |node|
			binding.irb
		end

		visit Prism::OptionalKeywordParameterNode do |node|
			OptionalKeywordParameterNode.new(
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::OptionalParameterNode do |node|
			OptionalParameterNode.new(
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::OrNode do |node|
			binding.irb
		end

		visit Prism::ParametersNode do |node|
			ParametersNode.new(
				requireds: node.requireds&.map { |n| visit(n) },
				optionals: node.optionals&.map { |n| visit(n) },
				rest: visit(node.rest),
				posts: node.posts&.map { |n| visit(n) },
				keywords: node.keywords&.map { |n| visit(n) },
				keyword_rest: visit(node.keyword_rest),
				block: visit(node.block)
			)
		end

		visit Prism::ParenthesesNode do |node|
			binding.irb
		end

		visit Prism::PinnedExpressionNode do |node|
			binding.irb
		end

		visit Prism::PinnedVariableNode do |node|
			binding.irb
		end

		visit Prism::PostExecutionNode do |node|
			binding.irb
		end

		visit Prism::PreExecutionNode do |node|
			binding.irb
		end

		visit Prism::ProgramNode do |node|
			visit(node.statements)
		end

		visit Prism::RangeNode do |node|
			binding.irb
		end

		visit Prism::RationalNode do |node|
			binding.irb
		end

		visit Prism::RedoNode do |node|
			binding.irb
		end

		visit Prism::RegularExpressionNode do |node|
			binding.irb
		end

		visit Prism::RequiredKeywordParameterNode do |node|
			RequiredKeywordParameterNode.new(
				name: node.name
			)
		end

		visit Prism::RequiredParameterNode do |node|
			RequiredParameterNode.new(
				name: node.name
			)
		end

		visit Prism::RescueModifierNode do |node|
			binding.irb
		end

		visit Prism::RescueNode do |node|
			RescueNode.new(
				exceptions: node.exceptions&.map { |n| visit(n) },
				reference: visit(node.reference),
				statements: visit(node.statements),
				subsequent: visit(node.subsequent),
			)
		end

		visit Prism::RestParameterNode do |node|
			RestParameterNode.new(
				name: node.name
			)
		end

		visit Prism::RetryNode do |node|
			binding.irb
		end

		visit Prism::ReturnNode do |node|
			binding.irb
		end

		visit Prism::SelfNode do |node|
			binding.irb
		end

		visit Prism::ShareableConstantNode do |node|
			binding.irb
		end

		visit Prism::SingletonClassNode do |node|
			binding.irb
		end

		visit Prism::SourceEncodingNode do |node|
			binding.irb
		end

		visit Prism::SourceFileNode do |node|
			binding.irb
		end

		visit Prism::SourceLineNode do |node|
			binding.irb
		end

		visit Prism::SplatNode do |node|
			SplatNode.new(
				expression: visit(node.expression)
			)
		end

		visit Prism::StatementsNode do |node|
			StatementsNode.new(
				body: node.body&.map { |n| visit(n) }
			)
		end

		visit Prism::StringNode do |node|
			StringNode.new(
				unescaped: node.unescaped
			)
		end

		visit Prism::SuperNode do |node|
			binding.irb
		end

		visit Prism::SymbolNode do |node|
			SymbolNode.new(
				unescaped: node.unescaped
			)
		end

		visit Prism::TrueNode do |node|
			TrueNode.new
		end

		visit Prism::UndefNode do |node|
			binding.irb
		end

		visit Prism::UnlessNode do |node|
			binding.irb
		end

		visit Prism::UntilNode do |node|
			binding.irb
		end

		visit Prism::WhenNode do |node|
			WhenNode.new(
				conditions: node.conditions&.map { |n| visit(n) },
				statements: visit(node.statements),
			)
		end

		visit Prism::WhileNode do |node|
			binding.irb
		end

		visit Prism::XStringNode do |node|
			binding.irb
		end

		visit Prism::YieldNode do |node|
			binding.irb
		end
	end
end
