# frozen_string_literal: true

test "alias global variable" do
	assert_refract <<~RUBY
		alias $foo $bar
	RUBY
end

test "alias method" do
	assert_refract <<~RUBY
		alias :foo :bar
	RUBY
end

test "alternation pattern" do
	assert_refract <<~RUBY
		foo => bar | baz
	RUBY
end

test "and" do
	assert_refract <<~RUBY
		left and right
	RUBY

	assert_refract <<~RUBY
		left && right
	RUBY
end

test "arguments" do
	assert_refract <<~RUBY
		foo(bar, baz)
	RUBY

	assert_refract <<~RUBY
		foo(bar, baz:)
	RUBY
end

test "array" do
	assert_refract <<~RUBY
		[
			1,
			2,
			3
		]
	RUBY
end

test "array pattern" do
	assert_refract <<~RUBY
		foo in [1, 2]
	RUBY

	assert_refract <<~RUBY
		foo in [1, 2]
	RUBY

	assert_refract <<~RUBY
		foo in [*bar]
	RUBY

	assert_refract <<~RUBY
		foo in Bar[]
	RUBY

	assert_refract <<~RUBY
		foo in Bar[1, 2, 3]
	RUBY
end

test "assoc splat" do
	assert_refract <<~RUBY
		{
			**foo
		}
	RUBY
end

test "back reference read" do
	assert_refract <<~RUBY
		$'
	RUBY

	assert_refract <<~RUBY
		$&
	RUBY

	assert_refract <<~RUBY
		$+
	RUBY
end

test "begin node" do
	assert_refract <<~RUBY
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
	RUBY
end

test "block" do
	assert_refract <<~RUBY
		foo {
			"Hello"
		}
	RUBY

	assert_refract <<~RUBY
		foo {
			"Hello"
		}
	RUBY

	assert_refract <<~RUBY
		foo(bar: 1) {
			"Hello"
		}
	RUBY
end

test "block argument" do
	assert_refract <<~RUBY
		foo(bar: 1, &baz)
	RUBY

	assert_refract <<~RUBY
		foo(bar: 1, &)
	RUBY
end

test "block local variable" do
	assert_refract <<~RUBY
		a { |; b|
			b
		}
	RUBY
end

test "block parameter" do
	assert_refract <<~RUBY
		foo { |a, b = 1, *c, d, e:, f: 1, **g, &h|
			a.+(b)
		}
	RUBY
end

test "def" do
	assert_refract <<~RUBY
		def Foo.bar(a, b = 1, *c, d, e:, f: 1, **g, &h)
			nil
		end
	RUBY

	assert_refract <<~RUBY
		def foo(*)
		end
	RUBY

	assert_refract <<~RUBY
		def foo(**)
		end
	RUBY

	assert_refract <<~RUBY
		def foo(&)
		end
	RUBY

	assert_refract <<~RUBY
		def foo(...)
		end
	RUBY
end

test "break" do
	assert_refract <<~RUBY
		break foo
	RUBY
end

test "call and write" do
	assert_refract <<~RUBY
		foo.bar &&= value
	RUBY
end

test "call operator write" do
	assert_refract <<~RUBY
		foo.bar += baz
	RUBY
end

test "call or write" do
	assert_refract <<~RUBY
		foo.bar ||= value
	RUBY
end

test "call target" do
	assert_refract <<~RUBY
		foo.bar, = 1
	RUBY
end

test "capture pattern" do
	assert_refract <<~RUBY
		foo => [bar => baz]
	RUBY
end

test "case match" do
	assert_refract <<~RUBY
		case true
		in false
			b
		else
			c
		end
	RUBY
end

test "case" do
	assert_refract <<~RUBY
		case true
		when false
			b
		else
			c
		end
	RUBY
end

test "class" do
	assert_refract <<~RUBY
		class Foo
		end
	RUBY

	assert_refract <<~RUBY
		class Foo < A::B
			def bar
			end
		end
	RUBY
end

test "class variable and write" do
	assert_refract <<~RUBY
		@@target &&= value
	RUBY
end

test "class variable operator write" do
	assert_refract <<~RUBY
		@@target += value
	RUBY
end

test "class variable or write" do
	assert_refract <<~RUBY
		@@target ||= value
	RUBY
end

def assert_refract(input)
	tree = Prism.parse(input).value
	node = Refract::Converter.new.visit(tree)
	result = Refract::Formatter.new.format_node(node)

	assert_equal_ruby result, input.strip
	assert_equal result, input.strip
end
