# frozen_string_literal: true

class NodeTest < Quickdraw::Test
	class RenamedCallNode < Refract::CallNode
	end

	def convert(source)
		Refract::Converter.new.visit(Prism.parse(source).value)
	end

	def call
		convert("foo(1, 2)").statements.body.first
	end

	test "copy replaces attributes and keeps the rest" do
		original = call
		copy = original.copy(name: :bar)

		assert_equal copy.name, :bar
		assert_same copy.arguments, original.arguments
		assert_same copy.prism_node, original.prism_node
		assert_equal original.name, :foo
		assert copy.frozen?
	end

	test "copy validates attributes" do
		assert_raises(NoMatchingPatternError) { call.copy(name: "bar") }
	end

	test "copy rejects unknown attributes" do
		assert_raises(ArgumentError) { call.copy(nam: :bar) }
	end

	test "copy keeps the class of a subclass" do
		node = RenamedCallNode.new(name: :foo)
		assert_equal node.copy(name: :bar).class, RenamedCallNode
	end

	test "a subclass whose constructor forwards keywords keeps its superclass's attributes" do
		subclass = Class.new(Refract::CallNode) do
			def initialize(tag: nil, **)
				@tag = tag
				super(**)
			end

			attr_reader :tag
		end

		node = subclass.new(name: :foo, tag: :a)
		copy = node.copy(name: :bar)

		assert_equal subclass.attributes, [:tag, *Refract::CallNode.attributes]
		assert_equal [copy.class, copy.name, copy.tag], [subclass, :bar, :a]
		assert_equal node.copy(tag: :b).tag, :b

		forwarding = Class.new(Refract::CallNode) do
			def initialize(...) = super
		end

		assert_equal forwarding.attributes, Refract::CallNode.attributes
		assert_equal forwarding.new(name: :foo).copy(name: :bar).name, :bar
	end

	test "child arrays are frozen, so copies can share them" do
		original = call
		copy = original.copy

		assert_raises(FrozenError) { copy.arguments.arguments << Refract::NilNode.new }
		assert_equal original.arguments.arguments.length, 2
	end

	test "arrays and strings passed to a node are frozen" do
		body = [Refract::NilNode.new]
		Refract::StatementsNode.new(body:)
		assert body.frozen?

		unescaped = +"foo"
		Refract::StringNode.new(unescaped:)
		assert unescaped.frozen?
	end

	test "prism node" do
		assert Prism::CallNode === call.prism_node
		assert_nil Refract::NilNode.new.prism_node
	end

	test "subclasses dispatch to their own visit method" do
		visitor = Class.new(Refract::BasicVisitor) do
			visit(Refract::CallNode) { |node| :call }
			visit(RenamedCallNode) { |node| :renamed_call }
		end.new

		assert_equal visitor.visit(RenamedCallNode.new(name: :a)), :renamed_call
		assert_equal visitor.visit(Refract::CallNode.new(name: :b)), :call
		assert_equal visitor.visit(RenamedCallNode.new(name: :c)), :renamed_call
		assert_equal RenamedCallNode.type, "renamed_call_node"
		assert_equal RenamedCallNode.visit_method, :visit_renamed_call_node
	end

	test "anonymous node classes raise a clear error" do
		node = Class.new(Refract::CallNode).new(name: :foo)

		error = assert_raises(ArgumentError) { node.accept(Refract::Visitor.new) }
		assert_match(error.message, /Anonymous node classes have no type/)
	end

	test "a node class named after it's defined dispatches by that name" do
		node_class = Class.new(Refract::CallNode)
		# Quickdraw wraps test files in an anonymous module, which TruffleRuby doesn't name constants under.
		Object.const_set(:RefractLaterNamedNode, node_class)

		visitor = Class.new(Refract::BasicVisitor) do
			visit(node_class) { |node| node.name }
		end.new

		assert_equal node_class.type, "refract_later_named_node"
		assert_equal visitor.visit(node_class.new(name: :foo)), :foo
	ensure
		Object.__send__(:remove_const, :RefractLaterNamedNode) if Object.const_defined?(:RefractLaterNamedNode, false)
	end

	test "attributes list required keywords first, in the same order on every Ruby" do
		assert_equal Refract::CallNode.attributes, [:name, :receiver, :arguments, :block, :safe_navigation, :variable_call, :attribute_write]
		assert_equal Refract::IfNode.attributes, [:predicate, :inline, :statements, :subsequent]
	end

	test "redefining initialize updates the attributes, copy and freeze" do
		node_class = Class.new(Refract::Node) do
			def initialize(prism_node: nil, a:)
				@prism_node = prism_node
				@a = a
				freeze
			end

			attr_reader :a
		end

		assert_equal node_class.attributes, [:a]

		node_class.class_eval do
			def initialize(prism_node: nil, a:, b:)
				@prism_node = prism_node
				@a = a
				@b = b
				freeze
			end

			attr_reader :b
		end

		node = node_class.new(a: [1], b: +"b")
		copy = node.copy(b: {})

		assert_equal node_class.attributes, [:a, :b]
		assert_equal [copy.a, copy.b], [[1], {}]
		assert [node.a, node.b, copy.b].all?(&:frozen?)
	end

	test "format node" do
		assert_equal Refract.format_node(call), "foo(1, 2)"
		assert_equal Class.new { include Refract }.new.format_node(call), "foo(1, 2)"
	end
end
