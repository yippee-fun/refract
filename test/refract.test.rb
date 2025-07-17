# frozen_string_literal: true

test "alias global variable" do
	assert_refract <<~RUBY
		alias $foo $bar
	RUBY
end

test "global variable write" do
	assert_refract <<~RUBY
		$foo = 1
	RUBY
end

test "global variable and write" do
	assert_refract <<~RUBY
		$foo &&= 1
	RUBY
end

test "global variable or write" do
	assert_refract <<~RUBY
		$foo ||= 1
	RUBY
end

test "global variable operator write" do
	assert_refract <<~RUBY
		$foo += 1
	RUBY
end

test "global variable target" do
	assert_refract <<~RUBY
		$foo, $bar = [
			1,
			2
		]
	RUBY
end

test "rational number" do
	assert_refract <<~RUBY
		1r
	RUBY

	assert_refract <<~RUBY
		3.14r
	RUBY
end

test "imaginary number" do
	assert_refract <<~RUBY
		1i
	RUBY

	assert_refract <<~RUBY
		3.14i
	RUBY
end

test "regular expression" do
	assert_refract <<~RUBY
		/foo/
	RUBY

	assert_refract <<~RUBY
		/bar/i
	RUBY
end

test "xstring" do
	assert_refract <<~RUBY
		`echo hello`
	RUBY

	assert_refract <<~RUBY
		`ls -la`
	RUBY
end

test "super" do
	assert_refract <<~RUBY
		super
	RUBY

	assert_refract <<~RUBY
		super(1, 2)
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

test "instance variable and write" do
	assert_refract <<~RUBY
		@foo &&= 1
	RUBY
end

test "instance variable operator write" do
	assert_refract <<~RUBY
		@foo += 1
	RUBY
end

test "instance variable or write" do
	assert_refract <<~RUBY
		@foo ||= 1
	RUBY
end

test "instance variable target" do
	assert_refract <<~RUBY
		@foo, @bar = [
			1,
			2
		]
	RUBY
end

test "local variable and write" do
	assert_refract <<~RUBY
		foo &&= 1
	RUBY
end

test "local variable operator write" do
	assert_refract <<~RUBY
		foo += 1
	RUBY
end

test "local variable or write" do
	assert_refract <<~RUBY
		foo ||= 1
	RUBY
end

test "source encoding" do
	assert_refract <<~RUBY
		__ENCODING__
	RUBY
end

test "source file" do
	assert_refract <<~RUBY
		__FILE__
	RUBY
end

test "source line" do
	assert_refract <<~RUBY
		__LINE__
	RUBY
end

test "defined" do
	assert_refract <<~RUBY
		defined?(foo)
	RUBY

	assert_refract <<~RUBY
		defined?(@bar)
	RUBY
end

test "undef" do
	assert_refract <<~RUBY
		undef :foo
	RUBY

	assert_refract <<~RUBY
		undef :foo, :bar, :baz
	RUBY
end

test "singleton class" do
	assert_refract <<~RUBY
		class << self
			def foo
				"bar"
			end
		end
	RUBY

	assert_refract <<~RUBY
		class << obj
			attr_reader(:value)
		end
	RUBY
end

test "rescue modifier" do
	assert_refract <<~RUBY
		foo rescue bar
	RUBY

	assert_refract <<~RUBY
		dangerous_operation rescue nil
	RUBY
end

test "shareable constant" do
	assert_refract <<~RUBY
		CONST = {
			a: 1,
			b: 2
		}
	RUBY
end

test "lambda" do
	assert_refract <<~RUBY
		lambda {
			42
		}
	RUBY

	assert_refract <<~RUBY
		-> (x, y) {
			x.+(y)
		}
	RUBY
end

test "constant path write" do
	assert_refract <<~RUBY
		Foo::Bar = 42
	RUBY

	assert_refract <<~RUBY
		::TopLevel::CONST = "value"
	RUBY
end

test "constant path and write" do
	assert_refract <<~RUBY
		Foo::Bar &&= 42
	RUBY
end

test "constant path or write" do
	assert_refract <<~RUBY
		Foo::Bar ||= 42
	RUBY
end

test "constant path operator write" do
	assert_refract <<~RUBY
		Foo::Bar += 1
	RUBY
end

test "constant path target" do
	assert_refract <<~RUBY
		Foo::Bar, Baz::Qux = [
			1,
			2
		]
	RUBY
end

test "interpolated symbol" do
	assert_refract <<~RUBY
		bar = "test"
		:"foo\#{bar}baz"
	RUBY

	assert_refract <<~RUBY
		expr = 42
		:"\#{expr}"
	RUBY
end

test "interpolated regular expression" do
	assert_refract <<~RUBY
		bar = "test"
		/foo\#{bar}baz/
	RUBY

	assert_refract <<~RUBY
		pattern = "test"
		/\#{pattern}/i
	RUBY
end

test "interpolated xstring" do
	assert_refract <<~RUBY
		name = "world"
		`echo \#{name}`
	RUBY

	assert_refract <<~RUBY
		dir = "/tmp"
		`ls -l \#{dir}`
	RUBY
end

test "for loop" do
	assert_refract <<~RUBY
		for i in [
			1,
			2,
			3
		]
			puts(i)
		end
	RUBY

	assert_refract <<~RUBY
		for x, y in pairs
			process(x, y)
		end
	RUBY
end

test "flip flop" do
	assert_refract <<~RUBY
		if (start..finish)
			do_something
		end
	RUBY

	assert_refract <<~RUBY
		if (first...last)
			process
		end
	RUBY
end

test "it local variable" do
	assert_refract <<~RUBY
		items.each {
			puts(it)
		}
	RUBY
end

test "it parameters" do
	assert_refract <<~RUBY
		items.each {
			process(it)
		}
	RUBY
end

test "numbered reference" do
	assert_refract <<~RUBY
		$1
	RUBY

	assert_refract <<~RUBY
		$2
	RUBY
end

test "forwarding arguments" do
	assert_refract <<~RUBY
		def foo(...)
			bar(...)
		end
	RUBY
end

test "match write" do
	assert_refract <<~RUBY
		/(?<name>\\w+)/.=~("hello")
	RUBY

	assert_refract <<~RUBY
		/(?<x>\\d+)-(?<y>\\d+)/.=~("123-456")
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

test "find pattern" do
	assert_refract <<~RUBY
		foo in [*, 1, *]
	RUBY

	assert_refract <<~RUBY
		foo in [*, 1, 2, *]
	RUBY

	assert_refract <<~RUBY
		foo in [*a, 1, *b]
	RUBY

	assert_refract <<~RUBY
		foo in [*a, 1, 2, 3, *b]
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

test "begin" do
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

test "class variable read" do
	assert_refract <<~RUBY
		@@foo
	RUBY
end

test "class variable target" do
	assert_refract <<~RUBY
		@@foo, @@bar = baz
	RUBY
end

test "class variable target" do
	assert_refract <<~RUBY
		@@foo = 1
	RUBY
end

test "module" do
	assert_refract <<~RUBY
		module Foo
		end
	RUBY
end

test "local variable write" do
	assert_refract <<~RUBY
		foo = 1
	RUBY
end

test "interpolated string" do
	assert_refract <<~RUBY
		"hello \#{name}!"
	RUBY

	assert_refract <<~RUBY
		"hello \#{"\#{name}"}!"
	RUBY

	assert_refract <<~RUBY
		"hello \#@name"
	RUBY
end

test "float" do
	assert_refract <<~RUBY
		1.2345678910111213141516171819202122232425262728293031323334353637383940
	RUBY
end

test "yield" do
	assert_refract <<~RUBY
		yield(foo)
	RUBY
end

test "instance variable write" do
	assert_refract <<~RUBY
		@foo = 1
	RUBY
end

test "instance variable read" do
	assert_refract <<~RUBY
		@foo
	RUBY
end

test "constant and write" do
	assert_refract <<~RUBY
		Target &&= value
	RUBY
end

test "constant operator write" do
	assert_refract <<~RUBY
		Target += value
	RUBY
end

test "constant or write" do
	assert_refract <<~RUBY
		Target ||= value
	RUBY
end

test "constant write" do
	assert_refract <<~RUBY
		FOO = 1
	RUBY
end

test "constant target" do
	assert_refract <<~RUBY
		FOO, bar = [
			1,
			2
		]
	RUBY
end

test "or" do
	assert_refract <<~RUBY
		left or right
	RUBY

	assert_refract <<~RUBY
		left || right
	RUBY
end

test "if" do
	assert_refract <<~RUBY
		if foo
			bar
		end
	RUBY

	assert_refract <<~RUBY
		if foo
			bar
		else
			baz
		end
	RUBY

	assert_refract <<~RUBY
		if foo
			bar
		elsif baz
			qux
		else
			quux
		end
	RUBY
end

test "unless" do
	assert_refract <<~RUBY
		unless foo
			bar
		end
	RUBY

	assert_refract <<~RUBY
		unless foo
			bar
		else
			baz
		end
	RUBY
end

test "while" do
	assert_refract <<~RUBY
		while foo
			bar
		end
	RUBY
end

test "until" do
	assert_refract <<~RUBY
		until foo
			bar
		end
	RUBY
end

test "next" do
	assert_refract <<~RUBY
		loop {
			if foo
				next
			end
			bar
		}
	RUBY

	assert_refract <<~RUBY
		loop {
			next 42
		}
	RUBY
end

test "return" do
	assert_refract <<~RUBY
		def foo
			return
		end
	RUBY

	assert_refract <<~RUBY
		def foo
			return 42
		end
	RUBY
end

test "redo" do
	assert_refract <<~RUBY
		loop {
			redo
		}
	RUBY
end

test "retry" do
	assert_refract <<~RUBY
		begin
			foo
		rescue
			retry
		end
	RUBY
end

test "parentheses" do
	assert_refract <<~RUBY
		(1.+(2)).*(3)
	RUBY

	assert_refract <<~RUBY
		(foo)
	RUBY
end

test "range" do
	assert_refract <<~RUBY
		1..10
	RUBY

	assert_refract <<~RUBY
		1...10
	RUBY

	assert_refract <<~RUBY
		..10
	RUBY

	assert_refract <<~RUBY
		1..
	RUBY
end

test "hash pattern" do
	assert_refract <<~RUBY
		foo => { a: 1, b: 2 }
	RUBY

	assert_refract <<~RUBY
		foo => { a: 1, b: 2, **c }
	RUBY
end

test "match last line" do
	assert_refract <<~RUBY
		if /foo/i
		end
	RUBY
end

test "index and write" do
	assert_refract <<~RUBY
		foo.bar[baz] &&= value
	RUBY

	assert_refract <<~RUBY
		foo[bar, &foo] &&= baz
	RUBY
end

test "index operator write" do
	assert_refract <<~RUBY
		foo.bar[baz] += value
	RUBY
end

test "index or write" do
	assert_refract <<~RUBY
		foo.bar[baz] ||= value
	RUBY
end

test "index target node" do
	assert_refract <<~RUBY
		foo[bar], = 1
	RUBY
end

test "interpolated match last line" do
	assert_refract <<~RUBY
		if /foo \#{bar} baz/
		end
	RUBY
end

test "no keywords parameter" do
	assert_refract <<~RUBY
		def a(**nil)
		end
	RUBY
end

test "pinned expression" do
	assert_refract <<~RUBY
		foo in ^(bar)
	RUBY
end

test "pinned variable" do
	assert_refract <<~RUBY
		foo in ^bar
	RUBY
end

test "numbered parameters" do
	assert_refract <<~RUBY
		-> {
			_1.+(_2)
		}
	RUBY
end

test "post execution" do
	assert_refract <<~RUBY
		END {
			foo
		}
	RUBY
end

test "pre execution" do
	assert_refract <<~RUBY
		BEGIN {
			foo
		}
	RUBY
end

def assert_refract(input)
	tree = Prism.parse(input).value
	node = Refract::Converter.new.visit(tree)
	result = Refract::Formatter.new.format_node(node)

	assert_equal_ruby result, input.strip
	assert_equal result, input.strip
end
