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
				prism_node: node,
				new_name: visit(node.new_name),
				old_name: visit(node.old_name),
			)
		end

		visit Prism::AliasMethodNode do |node|
			AliasMethodNode.new(
				prism_node: node,
				new_name: visit(node.new_name),
				old_name: visit(node.old_name),
			)
		end

		visit Prism::AlternationPatternNode do |node|
			AlternationPatternNode.new(
				prism_node: node,
				left: visit(node.left),
				right: visit(node.right),
			)
		end

		visit Prism::AndNode do |node|
			AndNode.new(
				prism_node: node,
				left: visit(node.left),
				operator: node.operator_loc.slice,
				right: visit(node.right),
			)
		end

		visit Prism::ArgumentsNode do |node|
			ArgumentsNode.new(
				prism_node: node,
				arguments: node.arguments&.map { |n| visit(n) },
			)
		end

		visit Prism::ArrayNode do |node|
			ArrayNode.new(
				prism_node: node,
				elements: node.elements&.map { |n| visit(n) },
			)
		end

		visit Prism::ArrayPatternNode do |node|
			ArrayPatternNode.new(
				prism_node: node,
				constant: visit(node.constant),
				requireds: node.requireds&.map { |n| visit(n) },
				rest: visit(node.rest),
				posts: node.posts&.map { |n| visit(n) },
			)
		end

		visit Prism::AssocNode do |node|
			AssocNode.new(
				prism_node: node,
				key: visit(node.key),
				value: visit(node.value),
			)
		end

		visit Prism::AssocSplatNode do |node|
			AssocSplatNode.new(
				prism_node: node,
				value: visit(node.value),
			)
		end

		visit Prism::BackReferenceReadNode do |node|
			BackReferenceReadNode.new(
				prism_node: node,
				name: node.name,
			)
		end

		visit Prism::BeginNode do |node|
			BeginNode.new(
				prism_node: node,
				statements: visit(node.statements),
				rescue_clause: visit(node.rescue_clause),
				else_clause: visit(node.else_clause),
				ensure_clause: visit(node.ensure_clause),
			)
		end

		visit Prism::BlockArgumentNode do |node|
			BlockArgumentNode.new(
				prism_node: node,
				expression: visit(node.expression),
			)
		end

		visit Prism::BlockLocalVariableNode do |node|
			BlockLocalVariableNode.new(
				prism_node: node,
				name: node.name,
			)
		end

		visit Prism::BlockNode do |node|
			BlockNode.new(
				prism_node: node,
				parameters: visit(node.parameters),
				body: visit(node.body),
			)
		end

		visit Prism::BlockParameterNode do |node|
			BlockParameterNode.new(
				prism_node: node,
				name: node.name,
			)
		end

		visit Prism::BlockParametersNode do |node|
			BlockParametersNode.new(
				prism_node: node,
				parameters: visit(node.parameters),
				locals: node.locals&.map { |n| visit(n) },
			)
		end

		visit Prism::BreakNode do |node|
			BreakNode.new(
				prism_node: node,
				arguments: visit(node.arguments),
			)
		end

		visit Prism::CallAndWriteNode do |node|
			CallAndWriteNode.new(
				prism_node: node,
				receiver: visit(node.receiver),
				read_name: node.read_name,
				value: visit(node.value),
			)
		end

		visit Prism::CallNode do |node|
			CallNode.new(
				prism_node: node,
				receiver: visit(node.receiver),
				message: node.message,
				arguments: visit(node.arguments),
				block: visit(node.block),
			)
		end

		visit Prism::CallOperatorWriteNode do |node|
			CallOperatorWriteNode.new(
				prism_node: node,
				receiver: visit(node.receiver),
				read_name: node.read_name,
				binary_operator: node.binary_operator,
				value: visit(node.value),
			)
		end

		visit Prism::CallOrWriteNode do |node|
			CallOrWriteNode.new(
				prism_node: node,
				receiver: visit(node.receiver),
				read_name: node.read_name,
				value: visit(node.value),
			)
		end

		visit Prism::CallTargetNode do |node|
			CallTargetNode.new(
				prism_node: node,
				receiver: visit(node.receiver),
				name: node.name,
			)
		end

		visit Prism::CapturePatternNode do |node|
			CapturePatternNode.new(
				prism_node: node,
				value: visit(node.value),
				target: visit(node.target),
			)
		end

		visit Prism::CaseMatchNode do |node|
			CaseMatchNode.new(
				prism_node: node,
				predicate: visit(node.predicate),
				conditions: node.conditions&.map { |n| visit(n) },
				else_clause: visit(node.else_clause),
			)
		end

		visit Prism::CaseNode do |node|
			CaseNode.new(
				prism_node: node,
				predicate: visit(node.predicate),
				conditions: node.conditions&.map { |n| visit(n) },
				else_clause: visit(node.else_clause),
			)
		end

		visit Prism::ClassNode do |node|
			ClassNode.new(
				prism_node: node,
				constant_path: visit(node.constant_path),
				superclass: visit(node.superclass),
				body: visit(node.body),
			)
		end

		visit Prism::ClassVariableAndWriteNode do |node|
			ClassVariableAndWriteNode.new(
				prism_node: node,
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::ClassVariableOperatorWriteNode do |node|
			ClassVariableOperatorWriteNode.new(
				prism_node: node,
				name: node.name,
				value: visit(node.value),
				binary_operator: node.binary_operator,
			)
		end

		visit Prism::ClassVariableOrWriteNode do |node|
			ClassVariableOrWriteNode.new(
				prism_node: node,
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::ClassVariableReadNode do |node|
			ClassVariableReadNode.new(
				prism_node: node,
				name: node.name,
			)
		end

		visit Prism::ClassVariableTargetNode do |node|
			ClassVariableTargetNode.new(
				prism_node: node,
				name: node.name,
			)
		end

		visit Prism::ClassVariableWriteNode do |node|
			ClassVariableWriteNode.new(
				prism_node: node,
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::ConstantAndWriteNode do |node|
			ConstantAndWriteNode.new(
				prism_node: node,
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::ConstantOperatorWriteNode do |node|
			ConstantOperatorWriteNode.new(
				prism_node: node,
				name: node.name,
				value: visit(node.value),
				binary_operator: node.binary_operator,
			)
		end

		visit Prism::ConstantOrWriteNode do |node|
			ConstantOrWriteNode.new(
				prism_node: node,
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::ConstantPathAndWriteNode do |node|
			ConstantPathAndWriteNode.new(
				prism_node: node,
				target: visit(node.target),
				value: visit(node.value),
			)
		end

		visit Prism::ConstantPathNode do |node|
			ConstantPath.new(
				prism_node: node,
				parent: visit(node.parent),
				name: node.name,
			)
		end

		visit Prism::ConstantPathOperatorWriteNode do |node|
			ConstantPathOperatorWriteNode.new(
				prism_node: node,
				target: visit(node.target),
				value: visit(node.value),
				binary_operator: node.binary_operator,
			)
		end

		visit Prism::ConstantPathOrWriteNode do |node|
			ConstantPathOrWriteNode.new(
				prism_node: node,
				target: visit(node.target),
				value: visit(node.value),
			)
		end

		visit Prism::ConstantPathTargetNode do |node|
			ConstantPathTargetNode.new(
				prism_node: node,
				parent: visit(node.parent),
				name: node.name,
			)
		end

		visit Prism::ConstantPathWriteNode do |node|
			ConstantPathWriteNode.new(
				prism_node: node,
				target: visit(node.target),
				value: visit(node.value),
			)
		end

		visit Prism::ConstantReadNode do |node|
			ConstantReadNode.new(
				prism_node: node,
				name: node.name,
			)
		end

		visit Prism::ConstantTargetNode do |node|
			ConstantTargetNode.new(
				prism_node: node,
				name: node.name,
			)
		end

		visit Prism::ConstantWriteNode do |node|
			ConstantWriteNode.new(
				prism_node: node,
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::DefNode do |node|
			DefNode.new(
				prism_node: node,
				name: node.name,
				receiver: visit(node.receiver),
				parameters: visit(node.parameters),
				body: visit(node.body),
			)
		end

		visit Prism::DefinedNode do |node|
			DefinedNode.new(
				prism_node: node,
				value: visit(node.value),
			)
		end

		visit Prism::ElseNode do |node|
			ElseNode.new(
				prism_node: node,
				statements: visit(node.statements),
			)
		end

		visit Prism::EmbeddedStatementsNode do |node|
			EmbeddedStatementsNode.new(
				prism_node: node,
				statements: visit(node.statements),
			)
		end

		visit Prism::EmbeddedVariableNode do |node|
			EmbeddedVariableNode.new(
				prism_node: node,
				variable: visit(node.variable),
			)
		end

		visit Prism::EnsureNode do |node|
			EnsureNode.new(
				prism_node: node,
				statements: visit(node.statements),
			)
		end

		visit Prism::FalseNode do |node|
			FalseNode.new(
				prism_node: node,
			)
		end

		visit Prism::FindPatternNode do |node|
			FindPatternNode.new(
				prism_node: node,
				constant: visit(node.constant),
				left: visit(node.left),
				requireds: node.requireds.map { |n| visit(n) },
				right: visit(node.right),
			)
		end

		visit Prism::FlipFlopNode do |node|
			FlipFlopNode.new(
				prism_node: node,
				left: visit(node.left),
				right: visit(node.right),
				exclude_end: node.exclude_end?,
			)
		end

		visit Prism::FloatNode do |node|
			FloatNode.new(
				prism_node: node,
				value: node.slice,
			)
		end

		visit Prism::ForNode do |node|
			ForNode.new(
				prism_node: node,
				index: visit(node.index),
				collection: visit(node.collection),
				statements: visit(node.statements),
			)
		end

		visit Prism::ForwardingArgumentsNode do |node|
			ForwardingArgumentsNode.new(
				prism_node: node,
			)
		end

		visit Prism::ForwardingParameterNode do |node|
			ForwardingParameterNode.new(
				prism_node: node,
			)
		end

		visit Prism::ForwardingSuperNode do |node|
			ForwardingSuperNode.new(
				prism_node: node,
				block: visit(node.block),
			)
		end

		visit Prism::GlobalVariableAndWriteNode do |node|
			GlobalVariableAndWriteNode.new(
				prism_node: node,
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::GlobalVariableOperatorWriteNode do |node|
			GlobalVariableOperatorWriteNode.new(
				prism_node: node,
				name: node.name,
				value: visit(node.value),
				binary_operator: node.binary_operator,
			)
		end

		visit Prism::GlobalVariableOrWriteNode do |node|
			GlobalVariableOrWriteNode.new(
				prism_node: node,
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::GlobalVariableReadNode do |node|
			GlobalVariableReadNode.new(
				prism_node: node,
				name: node.name,
			)
		end

		visit Prism::GlobalVariableTargetNode do |node|
			GlobalVariableTargetNode.new(
				prism_node: node,
				name: node.name,
			)
		end

		visit Prism::GlobalVariableWriteNode do |node|
			GlobalVariableWriteNode.new(
				prism_node: node,
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::HashNode do |node|
			HashNode.new(
				prism_node: node,
				elements: node.elements&.map { |n| visit(n) },
			)
		end

		visit Prism::HashPatternNode do |node|
			HashPatternNode.new(
				prism_node: node,
				elements: node.elements&.map { |n| visit(n) },
				rest: visit(node.rest),
			)
		end

		visit Prism::IfNode do |node|
			IfNode.new(
				prism_node: node,
				predicate: visit(node.predicate),
				statements: visit(node.statements),
				subsequent: visit(node.subsequent),
			)
		end

		visit Prism::ImaginaryNode do |node|
			ImaginaryNode.new(
				prism_node: node,
				numeric: visit(node.numeric),
			)
		end

		visit Prism::ImplicitNode do |node|
			ImplicitNode.new(
				prism_node: node,
				value: visit(node.value),
			)
		end

		visit Prism::ImplicitRestNode do |node|
			ImplicitRestNode.new(
				prism_node: node,
			)
		end

		visit Prism::InNode do |node|
			InNode.new(
				prism_node: node,
				pattern: visit(node.pattern),
				statements: visit(node.statements),
			)
		end

		visit Prism::IndexAndWriteNode do |node|
			IndexAndWriteNode.new(
				prism_node: node,
				receiver: visit(node.receiver),
				arguments: visit(node.arguments),
				block: visit(node.block),
				value: visit(node.value),
			)
		end

		visit Prism::IndexOperatorWriteNode do |node|
			IndexOperatorWriteNode.new(
				prism_node: node,
				receiver: visit(node.receiver),
				arguments: visit(node.arguments),
				block: visit(node.block),
				binary_operator: node.binary_operator,
				value: visit(node.value),
			)
		end

		visit Prism::IndexOrWriteNode do |node|
			IndexOrWriteNode.new(
				prism_node: node,
				receiver: visit(node.receiver),
				arguments: visit(node.arguments),
				block: visit(node.block),
				value: visit(node.value),
			)
		end

		visit Prism::IndexTargetNode do |node|
			IndexTargetNode.new(
				prism_node: node,
				receiver: visit(node.receiver),
				arguments: visit(node.arguments),
				block: visit(node.block),
			)
		end

		visit Prism::InstanceVariableAndWriteNode do |node|
			InstanceVariableAndWriteNode.new(
				prism_node: node,
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::InstanceVariableOperatorWriteNode do |node|
			InstanceVariableOperatorWriteNode.new(
				prism_node: node,
				name: node.name,
				value: visit(node.value),
				binary_operator: node.binary_operator,
			)
		end

		visit Prism::InstanceVariableOrWriteNode do |node|
			InstanceVariableOrWriteNode.new(
				prism_node: node,
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::InstanceVariableReadNode do |node|
			InstanceVariableReadNode.new(
				prism_node: node,
				name: node.name,
			)
		end

		visit Prism::InstanceVariableTargetNode do |node|
			InstanceVariableTargetNode.new(
				prism_node: node,
				name: node.name,
			)
		end

		visit Prism::InstanceVariableWriteNode do |node|
			InstanceVariableWriteNode.new(
				prism_node: node,
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::IntegerNode do |node|
			IntegerNode.new(
				prism_node: node,
				value: node.value,
			)
		end

		visit Prism::InterpolatedMatchLastLineNode do |node|
			InterpolatedMatchLastLineNode.new(
				prism_node: node,
				parts: node.parts&.map { |n| visit(n) },
				ignore_case: node.ignore_case?,
				multi_line: node.multi_line?,
				extended: node.extended?,
				once: node.once?,
			)
		end

		visit Prism::InterpolatedRegularExpressionNode do |node|
			InterpolatedRegularExpressionNode.new(
				prism_node: node,
				parts: node.parts.map { |part| visit(part) },
				ignore_case: node.ignore_case?,
				multi_line: node.multi_line?,
				extended: node.extended?,
				once: node.once?,
			)
		end

		visit Prism::InterpolatedStringNode do |node|
			InterpolatedStringNode.new(
				prism_node: node,
				parts: node.parts&.map { |n| visit(n) },
			)
		end

		visit Prism::InterpolatedSymbolNode do |node|
			InterpolatedSymbolNode.new(
				prism_node: node,
				parts: node.parts.map { |part| visit(part) },
			)
		end

		visit Prism::InterpolatedXStringNode do |node|
			InterpolatedXStringNode.new(
				prism_node: node,
				parts: node.parts.map { |part| visit(part) },
			)
		end

		visit Prism::ItLocalVariableReadNode do |node|
			ItLocalVariableReadNode.new(
				prism_node: node,
			)
		end

		visit Prism::ItParametersNode do |node|
			ItParametersNode.new(
				prism_node: node,
			)
		end

		visit Prism::KeywordHashNode do |node|
			KeywordHashNode.new(
				prism_node: node,
				elements: node.elements&.map { |n| visit(n) },
			)
		end

		visit Prism::KeywordRestParameterNode do |node|
			KeywordRestParameterNode.new(
				prism_node: node,
				name: node.name,
			)
		end

		visit Prism::LambdaNode do |node|
			LambdaNode.new(
				prism_node: node,
				parameters: visit(node.parameters),
				body: visit(node.body),
			)
		end

		visit Prism::LocalVariableAndWriteNode do |node|
			LocalVariableAndWriteNode.new(
				prism_node: node,
				name: node.name,
				value: visit(node.value),
				depth: node.depth,
			)
		end

		visit Prism::LocalVariableOperatorWriteNode do |node|
			LocalVariableOperatorWriteNode.new(
				prism_node: node,
				name: node.name,
				value: visit(node.value),
				binary_operator: node.binary_operator,
				depth: node.depth,
			)
		end

		visit Prism::LocalVariableOrWriteNode do |node|
			LocalVariableOrWriteNode.new(
				prism_node: node,
				name: node.name,
				value: visit(node.value),
				depth: node.depth,
			)
		end

		visit Prism::LocalVariableReadNode do |node|
			LocalVariableReadNode.new(
				prism_node: node,
				name: node.name,
			)
		end

		visit Prism::LocalVariableTargetNode do |node|
			LocalVariableTargetNode.new(
				prism_node: node,
				name: node.name,
			)
		end

		visit Prism::LocalVariableWriteNode do |node|
			LocalVariableWriteNode.new(
				prism_node: node,
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::MatchLastLineNode do |node|
			MatchLastLineNode.new(
				prism_node: node,
				unescaped: node.unescaped,
				ignore_case: node.ignore_case?,
				multi_line: node.multi_line?,
				extended: node.extended?,
				once: node.once?,
			)
		end

		visit Prism::MatchPredicateNode do |node|
			MatchPredicateNode.new(
				prism_node: node,
				value: visit(node.value),
				pattern: visit(node.pattern),
			)
		end

		visit Prism::MatchRequiredNode do |node|
			MatchRequiredNode.new(
				prism_node: node,
				value: visit(node.value),
				pattern: visit(node.pattern),
			)
		end

		visit Prism::MatchWriteNode do |node|
			MatchWriteNode.new(
				prism_node: node,
				call: visit(node.call),
				targets: node.targets.map { |t| visit(t) },
			)
		end

		visit Prism::MissingNode do |node|
			MissingNode.new(
				prism_node: node,
			)
		end

		visit Prism::ModuleNode do |node|
			ModuleNode.new(
				prism_node: node,
				constant_path: visit(node.constant_path),
				body: visit(node.body),
			)
		end

		visit Prism::MultiTargetNode do |node|
			MultiTargetNode.new(
				prism_node: node,
				lefts: node.lefts.map { |n| visit(n) },
				rest: visit(node.rest),
				rights: node.rights.map { |n| visit(n) },
			)
		end

		visit Prism::MultiWriteNode do |node|
			MultiWriteNode.new(
				prism_node: node,
				lefts: node.lefts&.map { |n| visit(n) },
				rest: visit(node.rest),
				rights: node.rights&.map { |n| visit(n) },
				value: visit(node.value),
			)
		end

		visit Prism::NextNode do |node|
			NextNode.new(
				prism_node: node,
				arguments: visit(node.arguments),
			)
		end

		visit Prism::NilNode do |node|
			NilNode.new(
				prism_node: node,
			)
		end

		visit Prism::NoKeywordsParameterNode do |node|
			NoKeywordsParameterNode.new(
				prism_node: node,
			)
		end

		visit Prism::NumberedParametersNode do |node|
			NumberedParametersNode.new(
				prism_node: node,
			)
		end

		visit Prism::NumberedReferenceReadNode do |node|
			NumberedReferenceReadNode.new(
				prism_node: node,
				number: node.number,
			)
		end

		visit Prism::OptionalKeywordParameterNode do |node|
			OptionalKeywordParameterNode.new(
				prism_node: node,
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::OptionalParameterNode do |node|
			OptionalParameterNode.new(
				prism_node: node,
				name: node.name,
				value: visit(node.value),
			)
		end

		visit Prism::OrNode do |node|
			OrNode.new(
				prism_node: node,
				left: visit(node.left),
				operator: node.operator_loc.slice,
				right: visit(node.right),
			)
		end

		visit Prism::ParametersNode do |node|
			ParametersNode.new(
				prism_node: node,
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
				prism_node: node,
				body: visit(node.body),
			)
		end

		visit Prism::PinnedExpressionNode do |node|
			PinnedExpressionNode.new(
				prism_node: node,
				expression: visit(node.expression),
			)
		end

		visit Prism::PinnedVariableNode do |node|
			PinnedVariableNode.new(
				prism_node: node,
				variable: visit(node.variable),
			)
		end

		visit Prism::PostExecutionNode do |node|
			PostExecutionNode.new(
				prism_node: node,
				statements: visit(node.statements),
			)
		end

		visit Prism::PreExecutionNode do |node|
			PreExecutionNode.new(
				prism_node: node,
				statements: visit(node.statements),
			)
		end

		visit Prism::ProgramNode do |node|
			ProgramNode.new(
				prism_node: node,
				statements: visit(node.statements),
			)
		end

		visit Prism::RangeNode do |node|
			RangeNode.new(
				prism_node: node,
				left: visit(node.left),
				right: visit(node.right),
				exclude_end: node.exclude_end?,
			)
		end

		visit Prism::RationalNode do |node|
			RationalNode.new(
				prism_node: node,
				numerator: node.numerator,
				denominator: node.denominator,
			)
		end

		visit Prism::RedoNode do |node|
			RedoNode.new(
				prism_node: node,
			)
		end

		visit Prism::RegularExpressionNode do |node|
			RegularExpressionNode.new(
				prism_node: node,
				unescaped: node.unescaped,
				ignore_case: node.ignore_case?,
				multi_line: node.multi_line?,
				extended: node.extended?,
				once: node.once?,
			)
		end

		visit Prism::RequiredKeywordParameterNode do |node|
			RequiredKeywordParameterNode.new(
				prism_node: node,
				name: node.name,
			)
		end

		visit Prism::RequiredParameterNode do |node|
			RequiredParameterNode.new(
				prism_node: node,
				name: node.name,
			)
		end

		visit Prism::RescueModifierNode do |node|
			RescueModifierNode.new(
				prism_node: node,
				expression: visit(node.expression),
				rescue_expression: visit(node.rescue_expression),
			)
		end

		visit Prism::RescueNode do |node|
			RescueNode.new(
				prism_node: node,
				exceptions: node.exceptions&.map { |n| visit(n) },
				reference: visit(node.reference),
				statements: visit(node.statements),
				subsequent: visit(node.subsequent),
			)
		end

		visit Prism::RestParameterNode do |node|
			RestParameterNode.new(
				prism_node: node,
				name: node.name,
			)
		end

		visit Prism::RetryNode do |node|
			RetryNode.new(
				prism_node: node,
			)
		end

		visit Prism::ReturnNode do |node|
			ReturnNode.new(
				prism_node: node,
				arguments: visit(node.arguments),
			)
		end

		visit Prism::SelfNode do |node|
			SelfNode.new(
				prism_node: node,
			)
		end

		visit Prism::ShareableConstantNode do |node|
			ShareableConstantNode.new(
				prism_node: node,
				write: visit(node.write),
			)
		end

		visit Prism::SingletonClassNode do |node|
			SingletonClassNode.new(
				prism_node: node,
				expression: visit(node.expression),
				body: visit(node.body),
			)
		end

		visit Prism::SourceEncodingNode do |node|
			SourceEncodingNode.new(
				prism_node: node,
			)
		end

		visit Prism::SourceFileNode do |node|
			SourceFileNode.new(
				prism_node: node,
			)
		end

		visit Prism::SourceLineNode do |node|
			SourceLineNode.new(
				prism_node: node,
			)
		end

		visit Prism::SplatNode do |node|
			SplatNode.new(
				prism_node: node,
				expression: visit(node.expression),
			)
		end

		visit Prism::StatementsNode do |node|
			StatementsNode.new(
				prism_node: node,
				body: node.body&.map { |n| visit(n) },
			)
		end

		visit Prism::StringNode do |node|
			StringNode.new(
				prism_node: node,
				unescaped: node.unescaped,
			)
		end

		visit Prism::SuperNode do |node|
			SuperNode.new(
				prism_node: node,
				arguments: visit(node.arguments),
				block: visit(node.block),
			)
		end

		visit Prism::SymbolNode do |node|
			SymbolNode.new(
				prism_node: node,
				unescaped: node.unescaped,
			)
		end

		visit Prism::TrueNode do |node|
			TrueNode.new(
				prism_node: node,
			)
		end

		visit Prism::UndefNode do |node|
			UndefNode.new(
				prism_node: node,
				names: node.names.map { |n| visit(n) },
			)
		end

		visit Prism::UnlessNode do |node|
			UnlessNode.new(
				prism_node: node,
				predicate: visit(node.predicate),
				statements: visit(node.statements),
				else_clause: visit(node.else_clause),
			)
		end

		visit Prism::UntilNode do |node|
			UntilNode.new(
				prism_node: node,
				predicate: visit(node.predicate),
				statements: visit(node.statements),
			)
		end

		visit Prism::WhenNode do |node|
			WhenNode.new(
				prism_node: node,
				conditions: node.conditions&.map { |n| visit(n) },
				statements: visit(node.statements),
			)
		end

		visit Prism::WhileNode do |node|
			WhileNode.new(
				prism_node: node,
				predicate: visit(node.predicate),
				statements: visit(node.statements),
			)
		end

		visit Prism::XStringNode do |node|
			XStringNode.new(
				prism_node: node,
				unescaped: node.unescaped,
			)
		end

		visit Prism::YieldNode do |node|
			YieldNode.new(
				prism_node: node,
				arguments: visit(node.arguments),
			)
		end
	end
end
