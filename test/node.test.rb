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

	test "format node" do
		assert_equal Refract.format_node(call), "foo(1, 2)"
	end
end
