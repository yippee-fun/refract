# frozen_string_literal: true

require "zeitwerk"
module Refract
	Loader = Zeitwerk::Loader.for_gem.tap do |loader|
		loader.ignore("#{__dir__}/ruby_lsp")
		loader.collapse("#{__dir__}/refract/errors")
		loader.setup
	end

	module NodeMod
		def snake_case_name
			demodularized_name = name.split("::").last
			demodularized_name.gsub(/(?<=[A-Z])(?=[A-Z][a-z])|(?<=[a-z\d])(?=[A-Z])/, "_").downcase
		end
	end

	module NodeInstance
		def accept(visitor)
			self.class.class_eval(<<~RUBY, __FILE__, __LINE__ + 1)
				# frozen_string_literal: true

				def accept(visitor)
					visitor.visit_#{self.class.snake_case_name}(self)
				end
			RUBY

			accept(visitor)
		end

		def update(**props)
			props.each do |k, v|
				self[k] = v
			end
		end
	end

	def self.Node(*props, &block)
		Struct.new(*props, &block).tap do |node|
			node.extend NodeMod
			node.include NodeInstance
		end
	end

	AliasGlobalVariableNode = Node(:new_name, :old_name)
	AliasMethodNode = Node(:new_name, :old_name)
	AlternationPatternNode = Node(:left, :right)
	AndNode = Node(:left, :operator, :right)
	ArgumentsNode = Node(:arguments)
	ArrayNode = Node(:elements)
	ArrayPatternNode = Node(:constant, :requireds, :rest, :posts)
	AssocNode = Node(:key, :value)
	AssocSplatNode = Node(:value)
	BackReferenceReadNode = Node(:name)
	BeginNode = Node(:statements, :rescue_clause, :else_clause, :ensure_clause)
	BlockArgumentNode = Node(:expression)
	BlockLocalVariableNode = Node(:name)
	BlockNode = Node(:parameters, :body)
	BlockParameterNode = Node(:name)
	BlockParametersNode = Node(:parameters, :locals)
	CallNode = Node(:receiver, :message, :arguments, :block)
	ConstantReadNode = Node(:name)
	DefNode = Node(:name, :receiver, :parameters, :body)
	ElseNode = Node(:statements)
	EnsureNode = Node(:statements)
	ForwardingParameterNode = Node()
	GlobalVariableReadNode = Node(:name)
	HashNode = Node(:elements)
	ImplicitNode = Node(:value)
	IntegerNode = Node(:value)
	KeywordHashNode = Node(:elements)
	KeywordRestParameterNode = Node(:name)
	LocalVariableReadNode = Node(:name)
	LocalVariableTargetNode = Node(:name)
	MatchPredicateNode = Node(:value, :pattern)
	MatchRequiredNode = Node(:value, :pattern)
	NilNode = Node()
	OptionalKeywordParameterNode = Node(:name, :value)
	OptionalParameterNode = Node(:name, :value)
	ParametersNode = Node(:requireds, :optionals, :rest, :posts, :keywords, :keyword_rest, :block)
	RequiredKeywordParameterNode = Node(:name)
	RequiredParameterNode = Node(:name)
	RescueNode = Node(:exceptions, :reference, :statements, :subsequent)
	RestParameterNode = Node(:name)
	SplatNode = Node(:expression)
	StatementsNode = Node(:body)
	StringNode = Node(:unescaped)
	SymbolNode = Node(:unescaped)
	BreakNode = Node(:arguments)
	CallAndWriteNode = Node(:receiver, :read_name, :value)
	CallOperatorWriteNode = Node(:receiver, :read_name, :binary_operator, :value)
	CallOrWriteNode = Node(:receiver, :read_name, :value)
	MultiWriteNode = Node(:lefts, :rest, :rights, :value)
	CallTargetNode = Node(:receiver, :name)
	ImplicitRestNode = Node()
	CapturePatternNode = Node(:value, :target)
	CaseMatchNode = Node(:predicate, :conditions, :else_clause)
	TrueNode = Node()
	InNode = Node(:pattern, :statements)
	FalseNode = Node()
	CaseNode = Node(:predicate, :conditions, :else_clause)
	WhenNode = Node(:conditions, :statements)
	ClassNode = Node(:constant_path, :superclass, :body)
	ConstantPath = Node(:parent, :name)
	ClassVariableAndWriteNode = Node(:name, :value)
	ClassVariableOperatorWriteNode = Node(:name, :value, :binary_operator)
	ClassVariableOrWriteNode = Node(:name, :value)
end
