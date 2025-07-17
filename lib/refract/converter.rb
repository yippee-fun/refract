# frozen_string_literal: true

module Refract
	class Converter < Prism::BasicVisitor
		def self.visit(node_class, &)
			raise ArgumentError unless Class === node_class && Prism::Node > node_class
			type = node_class.type.name

			define_method("visit_#{type}") do |node|
				raise ArgumentError unless node_class === node
				return_value = instance_exec(node, &)
				raise ArgumentError unless Node === return_value
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
				arguments: node.arguments&.map { |n| visit(n) },
			)
		end

		visit Prism::ArrayNode do |node|
			ArrayNode.new(
				elements: node.elements&.map { |n| visit(n) },
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
				value: visit(node.value),
			)
		end

		visit Prism::BackReferenceReadNode do |node|
			BackReferenceReadNode.new(
				name: node.name,
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
				expression: visit(node.expression),
			)
		end

		visit Prism::BlockLocalVariableNode do |node|
			BlockLocalVariableNode.new(
				name: node.name,
			)
		end

		visit Prism::BlockNode do |node|
			BlockNode.new(
				parameters: visit(node.parameters),
				body: visit(node.body),
			)
		end

		visit Prism::BlockParameterNode do |node|
			BlockParameterNode.new(
				name: node.name,
			)
		end

		visit Prism::BlockParametersNode do |node|
			BlockParametersNode.new(
				parameters: visit(node.parameters),
				locals: node.locals&.map { |n| visit(n) },
			)
		end

		visit Prism::BreakNode do |node|
			BreakNode.new(
				arguments: visit(node.arguments),
			)
		end

		visit Prism::CallAndWriteNode do |node|
			CallAndWriteNode.new(
				receiver: visit(node.receiver),
				read_name: node.read_name,
				value: visit(node.value),
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
			ClassVariableReadNode.new(
				name: node.name,
			)
		end

		visit Prism::ClassVariableTargetNode do |node|
			ClassVariableTargetNode.new(
				name: node.name,
			)
		end

		visit Prism::ClassVariableWriteNode do |node|
			ClassVariableWriteNode.new(
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::ConstantAndWriteNode do |node|
			ConstantAndWriteNode.new(
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::ConstantOperatorWriteNode do |node|
			ConstantOperatorWriteNode.new(
				name: node.name,
				value: visit(node.value),
				binary_operator: node.binary_operator,
			)
		end

		visit Prism::ConstantOrWriteNode do |node|
			ConstantOrWriteNode.new(
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::ConstantPathAndWriteNode do |node|
			ConstantPathAndWriteNode.new(
				target: visit(node.target),
				value: visit(node.value),
			)
		end

		visit Prism::ConstantPathNode do |node|
			ConstantPath.new(
				parent: visit(node.parent),
				name: node.name,
			)
		end

		visit Prism::ConstantPathOperatorWriteNode do |node|
			ConstantPathOperatorWriteNode.new(
				target: visit(node.target),
				value: visit(node.value),
				binary_operator: node.binary_operator,
			)
		end

		visit Prism::ConstantPathOrWriteNode do |node|
			ConstantPathOrWriteNode.new(
				target: visit(node.target),
				value: visit(node.value),
			)
		end

		visit Prism::ConstantPathTargetNode do |node|
			ConstantPathTargetNode.new(
				parent: visit(node.parent),
				name: node.name,
			)
		end

		visit Prism::ConstantPathWriteNode do |node|
			ConstantPathWriteNode.new(
				target: visit(node.target),
				value: visit(node.value),
			)
		end

		visit Prism::ConstantReadNode do |node|
			ConstantReadNode.new(
					name: node.name,
				)
		end

		visit Prism::ConstantTargetNode do |node|
			ConstantTargetNode.new(
				name: node.name,
			)
		end

		visit Prism::ConstantWriteNode do |node|
			ConstantWriteNode.new(
				name: node.name,
				value: visit(node.value),
			)
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
			DefinedNode.new(
				value: visit(node.value),
			)
		end

		visit Prism::ElseNode do |node|
			ElseNode.new(
				statements: visit(node.statements),
			)
		end

		visit Prism::EmbeddedStatementsNode do |node|
			EmbeddedStatementsNode.new(
				statements: visit(node.statements),
			)
		end

		visit Prism::EmbeddedVariableNode do |node|
			EmbeddedVariableNode.new(
				variable: visit(node.variable),
			)
		end

		visit Prism::EnsureNode do |node|
			EnsureNode.new(
				statements: visit(node.statements),
			)
		end

		visit Prism::FalseNode do |node|
			FalseNode.new
		end

		visit Prism::FindPatternNode do |node|
			FindPatternNode.new(
				constant: visit(node.constant),
				left: visit(node.left),
				requireds: node.requireds.map { |n| visit(n) },
				right: visit(node.right),
			)
		end

		visit Prism::FlipFlopNode do |node|
			FlipFlopNode.new(
				left: visit(node.left),
				right: visit(node.right),
				exclude_end: node.exclude_end?,
			)
		end

		visit Prism::FloatNode do |node|
			FloatNode.new(
				value: node.slice,
			)
		end

		visit Prism::ForNode do |node|
			ForNode.new(
				index: visit(node.index),
				collection: visit(node.collection),
				statements: visit(node.statements),
			)
		end

		visit Prism::ForwardingArgumentsNode do |node|
			ForwardingArgumentsNode.new
		end

		visit Prism::ForwardingParameterNode do |node|
			ForwardingParameterNode.new
		end

		visit Prism::ForwardingSuperNode do |node|
			ForwardingSuperNode.new(
				block: visit(node.block),
			)
		end

		visit Prism::GlobalVariableAndWriteNode do |node|
			GlobalVariableAndWriteNode.new(
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::GlobalVariableOperatorWriteNode do |node|
			GlobalVariableOperatorWriteNode.new(
				name: node.name,
				value: visit(node.value),
				binary_operator: node.binary_operator,
			)
		end

		visit Prism::GlobalVariableOrWriteNode do |node|
			GlobalVariableOrWriteNode.new(
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::GlobalVariableReadNode do |node|
			GlobalVariableReadNode.new(
				name: node.name,
			)
		end

		visit Prism::GlobalVariableTargetNode do |node|
			GlobalVariableTargetNode.new(
				name: node.name,
			)
		end

		visit Prism::GlobalVariableWriteNode do |node|
			GlobalVariableWriteNode.new(
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::HashNode do |node|
			HashNode.new(
				elements: node.elements&.map { |n| visit(n) },
			)
		end

		visit Prism::HashPatternNode do |node|
			HashPatternNode.new(
				elements: node.elements&.map { |n| visit(n) },
				rest: visit(node.rest),
			)
		end

		visit Prism::IfNode do |node|
			IfNode.new(
				predicate: visit(node.predicate),
				statements: visit(node.statements),
				subsequent: visit(node.subsequent),
			)
		end

		visit Prism::ImaginaryNode do |node|
			ImaginaryNode.new(
				numeric: visit(node.numeric),
			)
		end

		visit Prism::ImplicitNode do |node|
			ImplicitNode.new(
				value: visit(node.value),
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
			IndexAndWriteNode.new(
				receiver: visit(node.receiver),
				arguments: visit(node.arguments),
				block: visit(node.block),
				value: visit(node.value),
			)
		end

		visit Prism::IndexOperatorWriteNode do |node|
			IndexOperatorWriteNode.new(
				receiver: visit(node.receiver),
				arguments: visit(node.arguments),
				block: visit(node.block),
				binary_operator: node.binary_operator,
				value: visit(node.value),
			)
		end

		visit Prism::IndexOrWriteNode do |node|
			IndexOrWriteNode.new(
				receiver: visit(node.receiver),
				arguments: visit(node.arguments),
				block: visit(node.block),
				value: visit(node.value),
			)
		end

		visit Prism::IndexTargetNode do |node|
			IndexTargetNode.new(
				receiver: visit(node.receiver),
				arguments: visit(node.arguments),
				block: visit(node.block),
			)
		end

		visit Prism::InstanceVariableAndWriteNode do |node|
			InstanceVariableAndWriteNode.new(
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::InstanceVariableOperatorWriteNode do |node|
			InstanceVariableOperatorWriteNode.new(
				name: node.name,
				value: visit(node.value),
				binary_operator: node.binary_operator,
			)
		end

		visit Prism::InstanceVariableOrWriteNode do |node|
			InstanceVariableOrWriteNode.new(
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::InstanceVariableReadNode do |node|
			InstanceVariableReadNode.new(
				name: node.name,
			)
		end

		visit Prism::InstanceVariableTargetNode do |node|
			InstanceVariableTargetNode.new(
				name: node.name,
			)
		end

		visit Prism::InstanceVariableWriteNode do |node|
			InstanceVariableWriteNode.new(
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::IntegerNode do |node|
			IntegerNode.new(
				value: node.value,
			)
		end

		visit Prism::InterpolatedMatchLastLineNode do |node|
			InterpolatedMatchLastLineNode.new(
				parts: node.parts&.map { |n| visit(n) },
				ignore_case: node.ignore_case?,
				multi_line: node.multi_line?,
				extended: node.extended?,
				once: node.once?,
			)
		end

		visit Prism::InterpolatedRegularExpressionNode do |node|
			InterpolatedRegularExpressionNode.new(
				parts: node.parts.map { |part| visit(part) },
				ignore_case: node.ignore_case?,
				multi_line: node.multi_line?,
				extended: node.extended?,
				once: node.once?,
			)
		end

		visit Prism::InterpolatedStringNode do |node|
			InterpolatedStringNode.new(
				parts: node.parts&.map { |n| visit(n) },
			)
		end

		visit Prism::InterpolatedSymbolNode do |node|
			InterpolatedSymbolNode.new(
				parts: node.parts.map { |part| visit(part) },
			)
		end

		visit Prism::InterpolatedXStringNode do |node|
			InterpolatedXStringNode.new(
				parts: node.parts.map { |part| visit(part) },
			)
		end

		visit Prism::ItLocalVariableReadNode do |node|
			ItLocalVariableReadNode.new
		end

		visit Prism::ItParametersNode do |node|
			ItParametersNode.new
		end

		visit Prism::KeywordHashNode do |node|
			KeywordHashNode.new(
				elements: node.elements&.map { |n| visit(n) },
			)
		end

		visit Prism::KeywordRestParameterNode do |node|
			KeywordRestParameterNode.new(
				name: node.name,
			)
		end

		visit Prism::LambdaNode do |node|
			LambdaNode.new(
				parameters: visit(node.parameters),
				body: visit(node.body),
			)
		end

		visit Prism::LocalVariableAndWriteNode do |node|
			LocalVariableAndWriteNode.new(
				name: node.name,
				value: visit(node.value),
				depth: node.depth,
			)
		end

		visit Prism::LocalVariableOperatorWriteNode do |node|
			LocalVariableOperatorWriteNode.new(
				name: node.name,
				value: visit(node.value),
				binary_operator: node.binary_operator,
				depth: node.depth,
			)
		end

		visit Prism::LocalVariableOrWriteNode do |node|
			LocalVariableOrWriteNode.new(
				name: node.name,
				value: visit(node.value),
				depth: node.depth,
			)
		end

		visit Prism::LocalVariableReadNode do |node|
			LocalVariableReadNode.new(
				name: node.name,
			)
		end

		visit Prism::LocalVariableTargetNode do |node|
			LocalVariableTargetNode.new(
				name: node.name,
			)
		end

		visit Prism::LocalVariableWriteNode do |node|
			LocalVariableWriteNode.new(
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::MatchLastLineNode do |node|
			MatchLastLineNode.new(
				unescaped: node.unescaped,
				ignore_case: node.ignore_case?,
				multi_line: node.multi_line?,
				extended: node.extended?,
				once: node.once?,
			)
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
			MatchWriteNode.new(
				call: visit(node.call),
				targets: node.targets.map { |t| visit(t) },
			)
		end

		visit Prism::MissingNode do |node|
			MissingNode.new
		end

		visit Prism::ModuleNode do |node|
			ModuleNode.new(
				constant_path: visit(node.constant_path),
				body: visit(node.body),
			)
		end

		visit Prism::MultiTargetNode do |node|
			MultiTargetNode.new(
				lefts: node.lefts.map { |n| visit(n) },
				rest: visit(node.rest),
				rights: node.rights.map { |n| visit(n) },
			)
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
			NextNode.new(
				arguments: visit(node.arguments),
			)
		end

		visit Prism::NilNode do |node|
			NilNode.new
		end

		visit Prism::NoKeywordsParameterNode do |node|
			NoKeywordsParameterNode.new
		end

		visit Prism::NumberedParametersNode do |node|
			raise NoMethodError, "Not implemented"
		end

		visit Prism::NumberedReferenceReadNode do |node|
			NumberedReferenceReadNode.new(
				number: node.number,
			)
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
			OrNode.new(
				left: visit(node.left),
				operator: node.operator_loc.slice,
				right: visit(node.right),
			)
		end

		visit Prism::ParametersNode do |node|
			ParametersNode.new(
				requireds: node.requireds&.map { |n| visit(n) },
				optionals: node.optionals&.map { |n| visit(n) },
				rest: visit(node.rest),
				posts: node.posts&.map { |n| visit(n) },
				keywords: node.keywords&.map { |n| visit(n) },
				keyword_rest: visit(node.keyword_rest),
				block: visit(node.block),
			)
		end

		visit Prism::ParenthesesNode do |node|
			ParenthesesNode.new(
				body: visit(node.body),
			)
		end

		visit Prism::PinnedExpressionNode do |node|
			PinnedExpressionNode.new(
				expression: visit(node.expression),
			)
		end

		visit Prism::PinnedVariableNode do |node|
			raise NoMethodError, "Not implemented"
		end

		visit Prism::PostExecutionNode do |node|
			raise NoMethodError, "Not implemented"
		end

		visit Prism::PreExecutionNode do |node|
			raise NoMethodError, "Not implemented"
		end

		visit Prism::ProgramNode do |node|
			visit(node.statements)
		end

		visit Prism::RangeNode do |node|
			RangeNode.new(
				left: visit(node.left),
				right: visit(node.right),
				exclude_end: node.exclude_end?,
			)
		end

		visit Prism::RationalNode do |node|
			RationalNode.new(
				numerator: node.numerator,
				denominator: node.denominator,
			)
		end

		visit Prism::RedoNode do |node|
			RedoNode.new
		end

		visit Prism::RegularExpressionNode do |node|
			RegularExpressionNode.new(
				unescaped: node.unescaped,
				ignore_case: node.ignore_case?,
				multi_line: node.multi_line?,
				extended: node.extended?,
				once: node.once?,
			)
		end

		visit Prism::RequiredKeywordParameterNode do |node|
			RequiredKeywordParameterNode.new(
				name: node.name,
			)
		end

		visit Prism::RequiredParameterNode do |node|
			RequiredParameterNode.new(
				name: node.name,
			)
		end

		visit Prism::RescueModifierNode do |node|
			RescueModifierNode.new(
				expression: visit(node.expression),
				rescue_expression: visit(node.rescue_expression),
			)
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
				name: node.name,
			)
		end

		visit Prism::RetryNode do |node|
			RetryNode.new
		end

		visit Prism::ReturnNode do |node|
			ReturnNode.new(
				arguments: visit(node.arguments),
			)
		end

		visit Prism::SelfNode do |node|
			SelfNode.new
		end

		visit Prism::ShareableConstantNode do |node|
			ShareableConstantNode.new(
				write: visit(node.write),
			)
		end

		visit Prism::SingletonClassNode do |node|
			SingletonClassNode.new(
				expression: visit(node.expression),
				body: visit(node.body),
			)
		end

		visit Prism::SourceEncodingNode do |node|
			SourceEncodingNode.new
		end

		visit Prism::SourceFileNode do |node|
			SourceFileNode.new
		end

		visit Prism::SourceLineNode do |node|
			SourceLineNode.new
		end

		visit Prism::SplatNode do |node|
			SplatNode.new(
				expression: visit(node.expression),
			)
		end

		visit Prism::StatementsNode do |node|
			StatementsNode.new(
				body: node.body&.map { |n| visit(n) },
			)
		end

		visit Prism::StringNode do |node|
			StringNode.new(
				unescaped: node.unescaped,
			)
		end

		visit Prism::SuperNode do |node|
			SuperNode.new(
				arguments: visit(node.arguments),
				block: visit(node.block),
			)
		end

		visit Prism::SymbolNode do |node|
			SymbolNode.new(
				unescaped: node.unescaped,
			)
		end

		visit Prism::TrueNode do |node|
			TrueNode.new
		end

		visit Prism::UndefNode do |node|
			UndefNode.new(
				names: node.names.map { |n| visit(n) },
			)
		end

		visit Prism::UnlessNode do |node|
			UnlessNode.new(
				predicate: visit(node.predicate),
				statements: visit(node.statements),
				else_clause: visit(node.else_clause),
			)
		end

		visit Prism::UntilNode do |node|
			UntilNode.new(
				predicate: visit(node.predicate),
				statements: visit(node.statements),
			)
		end

		visit Prism::WhenNode do |node|
			WhenNode.new(
				conditions: node.conditions&.map { |n| visit(n) },
				statements: visit(node.statements),
			)
		end

		visit Prism::WhileNode do |node|
			WhileNode.new(
				predicate: visit(node.predicate),
				statements: visit(node.statements),
			)
		end

		visit Prism::XStringNode do |node|
			XStringNode.new(
				unescaped: node.unescaped,
			)
		end

		visit Prism::YieldNode do |node|
			YieldNode.new(
				arguments: visit(node.arguments),
			)
		end
	end
end
