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

	assert_refract <<~RUBY
		def foo(&)
			super(&)
		end
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

test "source line keeps its original value" do
	assert_formats "\n\nfoo(__LINE__)", "foo(3)"

	synthesized = Refract::SourceLineNode.new
	assert_equal Refract::Formatter.new.format_node(synthesized).source, "__LINE__"
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
			attr_accessor(:value)
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

test "symbol" do
	assert_refract <<~RUBY
  :symbol
	RUBY

	assert_refract <<~RUBY
  :"symbol"
	RUBY

	assert_refract <<~RUBY
  :'symb"ol'
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

test "assoc arguments" do
	assert_refract <<~RUBY
		foo(bar: "baz", "quoted-symbol": "value", 'single-"quoted"': 123)
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
		foo if (foo = true)
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
		foo unless (foo = true)
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

	assert_refract <<~RUBY
		b.<<(i) while (i = a.pop)
	RUBY
end

test "until" do
	assert_refract <<~RUBY
		until foo
			bar
		end
	RUBY

	assert_refract <<~RUBY
		b.<<(i) until (i = a.pop)
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

test "lonly" do
	assert_refract <<~RUBY
		foo&.bar
	RUBY
end

def assert_refract(input)
	tree = Prism.parse(input).value
	node = Refract::Converter.new.visit(tree)
	result = Refract::Formatter.new.format_node(node).source

	assert_equal_ruby result, input.strip
	assert_equal result, input.strip
end

def assert_round_trip(input)
	result = SemanticTree.round_trip(input)

	assert(result.errors.empty?) do
		"Regenerated source has syntax errors:\n#{result.source}\n#{result.errors.map(&:message).join("\n")}"
	end

	refute(result.mismatch) do
		"Round trip changed meaning at #{result.mismatch.path.join(' > ')}:\n#{result.source}\n" \
			"original:    #{result.mismatch.original.inspect}\nregenerated: #{result.mismatch.regenerated.inspect}"
	end
end

def assert_formats(input, expected)
	tree = Prism.parse(input).value
	node = Refract::Converter.new.visit(tree)
	assert_equal Refract::Formatter.new.format_node(node).source, expected.strip
	assert_round_trip(input)
end

test "string escapes backslashes, quotes and interpolation sigils" do
	assert_formats %q{%q(back\slash #{a} #@b #$c "q")}, %q{"back\\\\slash \#{a} \#@b \#$c \"q\""}
	assert_formats %q{"a\\\\b"}, %q{"a\\\\b"}
	assert_formats %q{'#'}, %q{"#"}
	assert_formats %q{'#a'}, %q{"#a"}
end

test "string escapes control characters" do
	assert_formats %q{"a\tb\nc\r\e\0"}, %q{"a\tb\nc\r\e\x00"}
	assert_formats %q{"\0" "1"}, %q{"\x001"}
	assert_formats %q{"\x7F"}, %q{"\x7F"}
end

test "string keeps printable non-ASCII text" do
	assert_formats "\"h\u00E9llo \u65E5\u672C\"", "\"h\u00E9llo \u65E5\u672C\""
	assert_formats %q{"\u00e9"}, "\"\u00E9\""
	assert_formats %q{"\u0085"}, %q{"\u{85}"}
end

test "string with invalid encoding is escaped bytewise" do
	assert_formats %q{"\xff\xfe"}, %q{"\xFF\xFE"}
end

test "string prefers single quotes when that avoids escaping" do
	assert_formats %q{'say "hi"'}, %q{'say "hi"'}
	assert_formats %q{'say "hi" #{x}'}, %q{'say "hi" #{x}'}
	assert_formats %q{"it's \"hi\""}, %q{"it's \"hi\""}
end

test "interpolated string escapes its static parts" do
	assert_formats %q{"a\\\\#{b}\"#{c}"}, %q{"a\\\\#{b}\"#{c}"}
	assert_formats %q{"\#{a}#{b}"}, %q{"\#{a}#{b}"}
	assert_formats %q{"a#" "{b}"}, %q{"a\#{b}"}
end

test "adjacent string literals merge" do
	assert_formats %q{"a#{b}" "c" 'd'}, %q{"a#{b}cd"}
end

test "heredocs become escaped strings" do
	assert_formats <<~'INPUT', <<~'RUBY'
		<<~'EOS'
			a
			  #{b}
			\\c
		EOS
	INPUT
		"a\n  \#{b}\n\\\\c\n"
	RUBY

	assert_formats <<~'INPUT', %q{"a\n#{b}\n".strip}
		<<~EOS.strip
			a
			#{b}
		EOS
	INPUT
end

test "character literals" do
	assert_formats %q{?a}, %q{"a"}
	assert_formats %q{?\n}, %q{"\n"}
end

test "quoted symbols escape their content" do
	assert_formats %q{:"a\\\\b\"#{1}"}, %q{:"a\\\\b\"#{1}"}
	assert_formats %q{:"a\tb"}, %q{:"a\tb"}
	assert_formats %q{%s(a b)}, %q{:"a b"}
	assert_formats %q{:'#{a}'}, %q{:"\#{a}"}
end

test "symbols that are not valid bare symbols are quoted" do
	assert_formats %q{%i[a\ b c]}, "[\n\t:\"a b\",\n\t:c\n]"
	assert_formats %q{%i[#{a}]}, "[\n\t:\"\\\#{a}\"\n]"
end

test "operator and sigil symbols stay bare" do
	%w[:[]= :[] :! :!= :+@ :-@ :** :<=> :=== :=~ :<< :foo? :foo! :foo= :@a :@@a :$a :$1 :$~ :A].each do |symbol|
		assert_formats symbol, symbol
	end
end

test "hash keys that are not valid labels are quoted" do
	assert_formats %q{{:+ => 1, :a= => 2, :@a => 3, :"a b" => 4, a?: 5}}, <<~RUBY
		{
			"+": 1,
			"a=": 2,
			"@a": 3,
			"a b": 4,
			a?: 5
		}
	RUBY
end

test "xstrings escape backticks and interpolation" do
	assert_formats %q{%x(echo `a` \#{b} #{c})}, %q{`echo \`a\` \#{b} #{c}`}
	assert_formats %q{%x(a\\\\b)}, %q{`a\\\\b`}
end

test "word arrays" do
	assert_formats %q{%w[a\ b c\\d #{e}]}, "[\n\t\"a b\",\n\t\"c\\\\d\",\n\t\"\\\#{e}\"\n]"
	assert_formats %q{%W[a#{b}c d]}, "[\n\t\"a\#{b}c\",\n\t\"d\"\n]"
end

test "regular expressions escape unescaped slashes and interpolation sigils" do
	assert_formats %q{/a\/b/}, %q{/a\/b/}
	assert_formats %q{%r{a/b}}, %q{/a\/b/}
	assert_formats %q{%r{a\/b}}, %q{/a\/b/}
	assert_formats %q{/a\\\\/}, %q{/a\\\\/}
	assert_formats %q{/\#{a}\#@b/}, %q{/\#{a}\#@b/}
	assert_formats %q{%r{#{a}/b\d}}, %q{/#{a}\/b\d/}
end

test "regular expressions keep every flag" do
	assert_formats %q{/a/mixo}, %q{/a/imxo}
	assert_formats %q{/a/n}, %q{/a/n}
	assert_formats %q{/a/u}, %q{/a/u}
	assert_formats %q{/a/s}, %q{/a/s}
	assert_formats %q{/a/e}, %q{/a/e}
	assert_formats %q{/#{a}/n}, %q{/#{a}/n}
end

test "regular expressions in conditions" do
	assert_formats "if %r{a/b}n\n\tc\nend", "if /a\\/b/n\n\tc\nend"
	assert_formats "if %r{\#{a}/b}i\n\tc\nend", "if /\#{a}\\/b/i\n\tc\nend"
end

test "frozen string literal magic comment" do
	assert_formats "# frozen_string_literal: true\nx = \"a\"", "# frozen_string_literal: true\nx = \"a\""
	assert_formats "# frozen_string_literal: false\nx = \"a\"", "# frozen_string_literal: false\nx = \"a\""
	assert_formats "# frozen_string_literal: true\nx = __FILE__", "# frozen_string_literal: true\nx = __FILE__"
	assert_formats "# frozen_string_literal: true\nx = \"a\#{b}\"", "x = \"a\#{b}\""
	assert_formats "# frozen_string_literal: true\nx = 1", "x = 1"
end

test "source encoding magic comment" do
	assert_formats "# encoding: binary\nx = \"\\xFF\"", "# encoding: ASCII-8BIT\nx = \"\\xFF\""
	assert_formats "# encoding: us-ascii\nx = 1", "# encoding: US-ASCII\nx = 1"
end

test "receiverless calls without arguments keep their parentheses" do
	assert_formats "a = 1\na()", "a = 1\na()"
	assert_formats "Foo()", "Foo()"
	assert_formats "foo", "foo"
	assert_formats "foo?", "foo?"
	assert_formats "foo { }", "foo {\n\t\n}"
end

test "attribute writes use assignment syntax" do
	assert_formats "a.b = 1", "a.b = 1"
	assert_formats "a.b = (1)", "a.b = (1)"
	assert_formats "a&.b = 1", "a&.b = 1"
	assert_formats "a.b=(1)", "a.b = (1)"
	assert_formats "x = (a.b = 1)", "x = (a.b = 1)"
end

test "index writes use assignment syntax" do
	assert_formats "a[1] = 2", "a[1] = 2"
	assert_formats "a[1, 2] = 3", "a[1, 2] = 3"
	assert_formats "a[] = 1", "a[] = 1"
	assert_formats "a[*b] = 1", "a[*b] = 1"
end

test "call operator writes keep safe navigation" do
	assert_formats "a&.b += 1", "a&.b += 1"
	assert_formats "a&.b ||= 1", "a&.b ||= 1"
	assert_formats "a&.b &&= 1", "a&.b &&= 1"
end

test "super with explicit empty arguments" do
	assert_formats "super()", "super()"
	assert_formats "super() { }", "super() {\n\t\n}"
	assert_formats "super(&b)", "super(&b)"
	assert_formats "super(a) { }", "super(a) {\n\t\n}"
	assert_formats "super", "super"
end

test "nested multi targets keep their parentheses" do
	assert_formats "def foo((a, b)); end", "def foo((a, b))\nend"
	assert_formats "a, (b, c) = 1", "a, (b, c) = 1"
	assert_formats "a, (b,) = 1", "a, (b, ) = 1"
	assert_formats "foo { |(a, b), c| }", "foo { |(a, b), c|\n\t\n}"
	assert_formats "for a, b in c; end", "for a, b in c\n\t\nend"
end

test "array patterns keep rest and posts" do
	assert_formats "case x; in [a, *b, c]; end", "case x\nin [a, *b, c]\nend"
	assert_formats "case x; in [*, {a:}]; end", "case x\nin [*, { a: }]\nend"
	assert_formats "case x; in Foo(a, *); end", "case x\nin Foo[a, *]\nend"
end

test "hash patterns keep their constant" do
	assert_formats "case x; in Foo(a:); end", "case x\nin Foo[a:]\nend"
	assert_formats "case x; in Foo::Bar[a: 1, **rest]; end", "case x\nin Foo::Bar[a: 1, **rest]\nend"
end

test "match write uses the operator so named captures assign locals" do
	assert_formats "/(?<x>.)/ =~ y\nx", "/(?<x>.)/ =~ y\nx"
end

test "rational literals are exact" do
	assert_formats "1.0000000000000001r", "1.0000000000000001r"
	assert_formats "0.001r", "0.001r"
	assert_formats "-2.5r", "-2.5r"
	assert_formats "3r", "3r"

	synthesized = Refract::RationalNode.new(numerator: 1, denominator: 3)
	assert_equal Refract::Formatter.new.format_node(synthesized).source, "(1r/3)"
end

test "if inside the predicate of another if is not an elsif" do
	assert_formats "if (a ? b : c) then d end", "if (if a\n\tb\nelse\n\tc\nend)\n\td\nend"
	assert_formats "if a ? b : c then d end", "if if a\n\tb\nelse\n\tc\nend\n\td\nend"
end

test "keyword expressions after return, break, next and rescue are parenthesized" do
	assert_formats "return a ? b : c", "return (if a\n\tb\nelse\n\tc\nend)"
	assert_formats "foo { next a ? b : c }", "foo {\n\tnext (if a\n\t\tb\n\telse\n\t\tc\n\tend)\n}"
	assert_formats "foo { break a ? b : c }", "foo {\n\tbreak (if a\n\t\tb\n\telse\n\t\tc\n\tend)\n}"
	assert_formats "x rescue a ? b : c", "x rescue (if a\n\tb\nelse\n\tc\nend)"
	assert_formats "begin\nrescue a ? B : C\nend", "begin\n\t\nrescue (if a\n\tB\nelse\n\tC\nend)\nend"
end

test "alias of a back reference" do
	assert_formats "alias $MATCH $&", "alias $MATCH $&"
end

test "hash sign before characters that do not start interpolation is not escaped" do
	assert_formats %q{"#$% #@1 #{a}"}, %q{"\#$% \#@1 #{a}"}
	assert_formats %q{/[#$%]/}, %q{/[#$%]/}
	assert_formats %q{'#$1 #@@a #@b'}, %q{"\#$1 \#@@a \#@b"}
end

def source_map(input)
	node = Refract::Converter.new.visit(Prism.parse(input).value)
	Refract::Formatter.new.format_node(node).source_map
end

test "source map points each generated line at the outermost node that starts on it" do
	assert_equal source_map("foo(\n\tbar,\n\tbaz\n)"), [nil, 1]
	assert_equal source_map("a\n\nb"), [nil, 1, 3]
end

test "source map does not drift after strings that contain newlines" do
	assert_equal source_map("x = <<~EOS\n\ta\n\tb\nEOS\ny"), [nil, 1, 5]
	assert_equal source_map("x = /a\nb/x\ny"), [nil, 1, nil, 3]
end

test "source map accounts for magic comments" do
	assert_equal source_map("# frozen_string_literal: true\n\"a\""), [nil, 2, 2]
end

test "source map starting line" do
	node = Refract::Converter.new.visit(Prism.parse("a\nb").value)
	assert_equal Refract::Formatter.new(starting_line: 10).format_node(node).source_map[10..], [1, 2]
end

test "source map covers synthesized nodes with their nearest original ancestor" do
	program = Refract::Converter.new.visit(Prism.parse("def foo\n\tbar\nend").value)
	definition = program.statements.body.first
	synthesized = Refract::CallNode.new(name: :baz, variable_call: true)
	body = definition.body.copy(body: [*definition.body.body, synthesized])
	program = program.copy(statements: program.statements.copy(body: [definition.copy(body:)]))

	result = Refract::Formatter.new.format_node(program)
	assert_equal result.source, "def foo\n\tbar\n\tbaz\nend"
	assert_equal result.source_map, [nil, 1, 2, 2]
end

test "empty nested statements do not produce blank lines" do
	statements = Refract::StatementsNode.new(
		body: [
			Refract::CallNode.new(name: :a, variable_call: true),
			Refract::StatementsNode.new(body: [Refract::StatementsNode.new(body: [])]),
			Refract::MissingNode.new,
			Refract::CallNode.new(name: :b, variable_call: true),
		],
	)

	assert_equal Refract::Formatter.new.format_node(statements).source, "a\nb"
end

test "visitor stack is restored when a visit raises" do
	visitor = Class.new(Refract::Visitor) do
		attr_reader :stack

		visit Refract::CallNode do |node|
			raise ArgumentError
		end
	end.new

	node = Refract::Converter.new.visit(Prism.parse("[foo]").value)
	assert_raises(ArgumentError) { visitor.visit(node) }
	assert_equal visitor.stack, []
end

test "nodes support hash patterns" do
	node = Refract::Converter.new.visit(Prism.parse("foo(1)").value).statements.body.first

	assert((node in Refract::CallNode[name: :foo, receiver: nil]))
	refute((node in { name: :bar }))
	assert_equal node.deconstruct_keys([:name, :missing]), { name: :foo }
	assert_equal Refract::NilNode.new.deconstruct_keys(nil), {}
end

test "nodes have a short inspect" do
	node = Refract::CallNode.new(name: :foo, arguments: Refract::ArgumentsNode.new(arguments: [Refract::NilNode.new]))
	assert_equal node.inspect, "#<Refract::CallNode name: :foo, receiver: nil, arguments: #<Refract::ArgumentsNode arguments: [#<Refract::NilNode>]>, block: nil, safe_navigation: nil, variable_call: nil, attribute_write: nil>"
end

test "every node is frozen" do
	Refract::Loader.eager_load
	program = Refract::Converter.new.visit(Prism.parse("nil; self; true; false; __FILE__; __LINE__; __ENCODING__; -> { it }; -> { _1 }; def a(...) = b(...); def c(**nil) = 1; redo; retry").value)

	nodes = []
	collect = -> (node) do
		nodes << node
		node.class.attributes.each do |name|
			Array(node.public_send(name)).each { |child| collect.(child) if Refract::Node === child }
		end
	end
	collect.(program)

	assert_equal nodes.reject(&:frozen?), []
end

test "mutation visitor handles constant and-write and operator-write" do
	node = Refract::Converter.new.visit(Prism.parse("A &&= 1\nB += 2").value)
	result = Refract::MutationVisitor.new.visit(node)
	assert_equal Refract::Formatter.new.format_node(result).source, "A &&= 1\nB += 2"
end

test "renaming the value of shorthand hash syntax expands it" do
	renamer = Class.new(Refract::MutationVisitor) do
		visit Refract::LocalVariableReadNode do |node|
			node.copy(name: :renamed)
		end
	end

	node = Refract::Converter.new.visit(Prism.parse("a = 1\nfoo(a:)").value)
	result = renamer.new.visit(node)
	assert_equal Refract::Formatter.new.format_node(result).source, "a = 1\nfoo(a: renamed)"
	assert_equal Refract::Formatter.new.format_node(node).source, "a = 1\nfoo(a:)"
end

test "requiring refract on its own loads prism" do
	output = IO.popen([RbConfig.ruby, "-I", File.expand_path("../lib", __dir__), "-e", "require 'refract'; p Refract::Converter.new.visit(Prism.parse('1').value).type"], err: [:child, :out], &:read)
	assert_equal output, "\"program_node\"\n"
end

test "symbols that Ruby would normalize are quoted" do
	assert_formats %q{%i[!@ ~@ +@]}, "[\n\t:\"!@\",\n\t:\"~@\",\n\t:+@\n]"
	assert_formats %q{:!@}, %q{:!}
end

test "hash signs followed by a closing delimiter do not become interpolation" do
	assert_formats %q{'#$'}, %q{"\#$"}
	assert_formats %q{'#@'}, %q{"\#@"}
	assert_formats %q{%r{#$}}, %q{/\#$/}
	assert_formats %q{%x(#$)}, %q{`\#$`}
end

test "explicit index assignment calls keep method syntax" do
	assert_formats "a.[]=(1, 2)", "a.[]=(1, 2)"

	synthesized = Refract::CallNode.new(
		receiver: Refract::CallNode.new(name: :a, variable_call: true),
		name: :[]=,
		arguments: Refract::ArgumentsNode.new(arguments: [Refract::IntegerNode.new(value: 1), Refract::IntegerNode.new(value: 2)]),
	)
	assert_equal Refract::Formatter.new.format_node(synthesized).source, "a.[]=(1, 2)"
end

test "shareable constant value directive" do
	assert_formats "# shareable_constant_value: literal\nA = [1]\nB = 2", <<~RUBY
		# shareable_constant_value: literal
		A = [
			1
		]
		# shareable_constant_value: none
		# shareable_constant_value: literal
		B = 2
		# shareable_constant_value: none
	RUBY

	assert_formats "# shareable_constant_value: experimental_copy\nclass A\n\tB = []\nend\nC = []", <<~RUBY
		class A
			# shareable_constant_value: experimental_copy
			B = [
				
			]
			# shareable_constant_value: none
		end
		# shareable_constant_value: experimental_copy
		C = [
			
		]
		# shareable_constant_value: none
	RUBY
end

test "strings in when clauses and hash keys do not imply frozen_string_literal" do
	assert_formats "case a\nwhen \"b\" then {\"c\" => \"d\"}\nend", "case a\nwhen \"b\"\n\t{\n\t\t\"c\" => \"d\"\n\t}\nend"
end

test "shareable constant value directive is hoisted to the enclosing statement" do
	assert_formats "# shareable_constant_value: literal\nA = [] if false", <<~RUBY
		# shareable_constant_value: literal
		A = [
			
		] if false
		# shareable_constant_value: none
	RUBY

	assert_formats "# shareable_constant_value: literal\n(A = 1).freeze", <<~RUBY
		# shareable_constant_value: literal
		(A = 1).freeze
		# shareable_constant_value: none
	RUBY
end

test "low precedence receivers are parenthesized" do
	assert_formats "not(a and b)", "(a and b).!"
	assert_formats "not x = y", "(x = y).!"
	assert_formats "(a.b = 1).c", "(a.b = 1).c"
end

test "unicode escapes in a non UTF-8 source stay escaped" do
	assert_formats "# coding: us-ascii\nx = \"\\u00e9\" \"\\u0300\"", "# encoding: US-ASCII\nx = \"\\u{E9}\\u{300}\""
	assert_formats "# coding: us-ascii\nx = :\"\\u00e9\"", "# encoding: US-ASCII\nx = :\"\\u{E9}\""
end

test "a lone string in interpolation does not imply frozen_string_literal" do
	assert_formats "x = \"a\#{' '}\"", "x = \"a\#{\" \"}\""
end

test "adjacent literals keep the encoding of their non-ASCII parts" do
	assert_round_trip "# coding: us-ascii\nx = \"\" \"[\\u0300\" \"]\""
end

test "non-ASCII bare symbols are quoted in a non UTF-8 source" do
	assert_formats "# coding: US-ASCII\nx = %I[\\u00e9]", "# encoding: US-ASCII\nx = [\n\t:\"\\u{E9}\"\n]"
end

test "a mutable interpolated string does not imply frozen_string_literal: false" do
	assert_formats "# frozen_string_literal: true\nx = \"\#{'a'}\"\ny = 'b'", "# frozen_string_literal: true\nx = \"\#{\"a\"}\"\ny = \"b\""
end

test "nested shareable constant value directives restore the enclosing value" do
	assert_formats "# shareable_constant_value: literal\nA = [begin\n\tB = 1\nend]", <<~RUBY
		# shareable_constant_value: literal
		A = [
			begin
				# shareable_constant_value: literal
				B = 1
				# shareable_constant_value: literal
			end
		]
		# shareable_constant_value: none
	RUBY

	assert_formats "# shareable_constant_value: literal\nif A = 1\n\t# shareable_constant_value: none\n\tB = []\nend", <<~RUBY
		# shareable_constant_value: literal
		if A = 1
			# shareable_constant_value: none
			B = [
				
			]
			# shareable_constant_value: literal
		end
		# shareable_constant_value: none
	RUBY
end
