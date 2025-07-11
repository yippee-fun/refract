# frozen_string_literal: true

test "alias global variable" do
	assert_refract <<~INPUT, <<~OUTPUT
		alias $foo $bar
	INPUT
		alias $foo $bar
	OUTPUT
end

test "alias method" do
	assert_refract <<~INPUT, <<~OUTPUT
		alias foo bar
	INPUT
		alias :"foo" :"bar"
	OUTPUT
end

test "alternation pattern" do
	assert_refract <<~INPUT, <<~OUTPUT
		foo => bar | baz
	INPUT
		foo => bar | baz
	OUTPUT
end

test "and" do
	assert_refract <<~INPUT, <<~OUTPUT
		left and right
	INPUT
		left and right
	OUTPUT

	assert_refract <<~INPUT, <<~OUTPUT
		left && right
	INPUT
		left && right
	OUTPUT
end

test "arguments" do
	assert_refract <<~INPUT, <<~OUTPUT
		foo(bar, baz)
	INPUT
		foo(bar, baz)
	OUTPUT

	assert_refract <<~INPUT, <<~OUTPUT
		foo(bar, baz:)
	INPUT
		foo(bar, :"baz" => baz)
	OUTPUT
end

test "array" do
	assert_refract <<~INPUT, <<~OUTPUT
		[1, 2, 3]
	INPUT
		[
			1,
			2,
			3
		]
	OUTPUT
end

test "array pattern" do
	assert_refract <<~INPUT, <<~OUTPUT
		foo in 1, 2
	INPUT
		foo in [1, 2]
	OUTPUT

	assert_refract <<~INPUT, <<~OUTPUT
		foo in [1, 2]
	INPUT
		foo in [1, 2]
	OUTPUT

	assert_refract <<~INPUT, <<~OUTPUT
		foo in *bar
	INPUT
		foo in [*bar]
	OUTPUT

	assert_refract <<~INPUT, <<~OUTPUT
		foo in Bar[]
	INPUT
		foo in Bar[]
	OUTPUT

	assert_refract <<~INPUT, <<~OUTPUT
		foo in Bar[1, 2, 3]
	INPUT
		foo in Bar[1, 2, 3]
	OUTPUT
end

test "assoc splat" do
	assert_refract <<~INPUT, <<~OUTPUT
		{ **foo }
	INPUT
		{
			**foo
		}
	OUTPUT
end

test "back reference read" do
	assert_refract <<~INPUT, <<~OUTPUT
		$'
	INPUT
		$'
	OUTPUT

	assert_refract <<~INPUT, <<~OUTPUT
		$&
	INPUT
		$&
	OUTPUT

	assert_refract <<~INPUT, <<~OUTPUT
		$+
	INPUT
		$+
	OUTPUT
end

test "begin node" do
	assert_refract <<~INPUT, <<~OUTPUT
		begin
			a
		rescue b => c
			d
		rescue e => f
			g
		else
			h
		ensure
			i
		end
	INPUT
		begin
			a
		rescue b => c
			d
		rescue e => f
			g
		else
			h
		ensure
			i
		end
	OUTPUT
end

def assert_refract(input, output)
	tree = Prism.parse(input).value
	node = Refract::Converter.new.visit(tree)
	result = Refract::Formatter.new.format_node(node)

	assert_equal_ruby result, output.strip
	assert_equal result, output.strip
end
