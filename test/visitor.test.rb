# frozen_string_literal: true

class VisitorTest < Quickdraw::Test
	EVERY_NODE = <<~'RUBY'
		# frozen_string_literal: true
		# shareable_constant_value: literal
		X = [1]
		BEGIN { a }
		END { b }
		alias $new $old
		alias new_name old_name
		alias $x $&
		undef foo, bar
		a = 1
		a += 1
		a ||= 2
		a &&= 3
		b, (c, *d, e), f = 1, 2
		f, = g
		@a = @b
		@a += 1
		@a ||= 1
		@a &&= 1
		@a, = 1
		@@a = @@b
		@@a += 1
		@@a ||= 1
		@@a &&= 1
		@@a, = 1
		$a = $b
		$a += 1
		$a ||= 1
		$a &&= 1
		$a, = 1
		C = D
		C += 1
		C ||= 1
		C &&= 1
		C, = 1
		A::B = ::C
		A::B += 1
		A::B ||= 1
		A::B &&= 1
		A::B, = 1
		x.y = 1
		x.y += 1
		x.y ||= 1
		x.y &&= 1
		x.y, = 1
		x[1] = 2
		x[1] += 1
		x[1] ||= 1
		x[1] &&= 1
		x[1], = 1
		foo(1, *a, **b, &c)
		foo(k: 1, "s": 2, **h)
		{ a: 1, **h }
		[1, 2.0, 3r, 4i, "s", :sym, :"d#{a}", "i#{a}#@b", `x`, `x#{a}`, /r/, /r#{a}/, nil, true, false, self]
		1..2
		1...
		__FILE__; __LINE__; __ENCODING__
		$1; $&
		defined?(a)
		a && b || c and d or e
		not a
		if a then b elsif c then d else e end
		unless a then b else c end
		while a do b end
		until a do b end
		b while a
		for i, j in k do l end
		case a when 1, 2 then b else c end
		case a
		in [1, *r, 2] then 1
		in [*, 3, *] then 2
		in { k: 1, **rest } then 3
		in { k: } then 3
		in { **nil } then 3
		in Integer | Float => n if n then 4
		in ^a then 5
		in ^(a + 1) then 6
		in ^@a then 6
		in C[1] then 7
		in C(k: 1) then 7
		in 1.. then 7
		else 8
		end
		a in Integer
		a => b
		/(?<named>x)/ =~ s
		if /m/ then 1 end
		if /m#{a}/ then 1 end
		if (a == 1)..(a == 2) then 1 end
		begin
			a
		rescue A, B => e
			retry
		rescue => e
			e
		else
			b
		ensure
			c
		end
		a rescue b
		def m(a, b = 1, *c, d, e:, f: 2, **g, &h)
			yield 1
			super
			super(1)
			return 1
		end
		def n(...) = o(...)
		def o(*, **, &) = p(*, **, &)
		def q(**nil); end
		def self.r((a, b), c) = a
		class K < L; end
		class << self; end
		module M; end
		x.each { |a, (b, c); d| next a }
		x.each { break }
		loop { redo }
		-> (a) { a }
		-> { it }
		-> { _1 }
		foo { |;a| a }
		"a" "b"
		%w[a b]
		"#{a}"
		("#@a")
		(1; 2)
		a&.b
	RUBY

	class Recorder < Refract::Visitor
		attr_reader :visited

		def initialize
			super
			@visited = []
		end

		def around_visit(node)
			@visited << node
			yield(node)
		end
	end

	class Rebuilder < Refract::MutationVisitor
		attr_reader :visited

		def initialize
			super
			@visited = []
		end

		def around_visit(node)
			@visited << node
			yield(node).copy
		end
	end

	def convert(source)
		Refract::Converter.new.visit(Prism.parse(source).value)
	end

	def descendants(node)
		children = node.class.attributes.flat_map do |name|
			case node.public_send(name)
			in Refract::Node => child then [child]
			in Array => children then children.grep(Refract::Node)
			else []
			end
		end

		[node, *children.flat_map { |child| descendants(child) }]
	end

	def format(node)
		Refract::Formatter.new.format_node(node).source
	end

	test "visitor visits every child of every node" do
		source = %w[formatter converter].map { |name| File.read(File.expand_path("../lib/refract/#{name}.rb", __dir__)) }.join("\n")
		tree = convert(source)
		recorder = Recorder.new
		recorder.visit(tree)

		expected = descendants(tree)
		assert_equal recorder.visited.map(&:class).tally, expected.map(&:class).tally
		assert(recorder.visited.tally == expected.tally) { "Visitor skipped some nodes and visited others twice" }
	end

	test "visitor visits class variables" do
		recorder = Recorder.new
		recorder.visit(convert("@@a = @@b\n@@c, @@d = 1, 2"))

		assert_equal recorder.visited.map(&:type).grep(/class_variable/), [
			"class_variable_write_node",
			"class_variable_read_node",
			"class_variable_target_node",
			"class_variable_target_node",
		]
	end

	test "the every node source has every node a parse without errors can produce" do
		node_classes = Refract.constants.map { |name| Refract.const_get(name) }.select { |constant| Class === constant && constant < Refract::Node }

		assert_equal node_classes - descendants(convert(EVERY_NODE)).map(&:class), [Refract::MissingNode]
	end

	test "visitor visits every child of every node type" do
		tree = convert(EVERY_NODE)
		recorder = Recorder.new
		recorder.visit(tree)

		assert(recorder.visited.tally == descendants(tree).tally) { "Visitor skipped some nodes and visited others twice" }
	end

	test "mutation visitor visits every child of every node type and rebuilds it from the results" do
		tree = convert(EVERY_NODE)
		rebuilder = Rebuilder.new
		result = rebuilder.visit(tree)

		assert(rebuilder.visited.tally == descendants(tree).tally) { "Mutation visitor skipped some nodes and visited others twice" }
		assert_equal descendants(result) & descendants(tree), []
		assert_equal format(result), format(tree)
	end

	test "visitors accept nodes whose child lists are nil" do
		descendants(convert(EVERY_NODE)).uniq(&:class).each do |sample|
			lists = sample.class.attributes.select { |name| Array === sample.public_send(name) }
			next if lists.empty?

			node = sample.copy(**lists.to_h { |name| [name, nil] })
			recorder = Recorder.new
			recorder.visit(node)

			assert_equal recorder.visited, descendants(node)
			assert_equal Refract::MutationVisitor.new.visit(node).deconstruct_keys(lists), lists.to_h { |name| [name, nil] }
		end
	end

	test "visitors accept missing nodes" do
		missing = Refract::MissingNode.new

		refute_raises { Refract::Visitor.new.visit(missing) }
		assert_same Refract::MutationVisitor.new.visit(missing), missing
	end

	test "visit each skips nil" do
		refute_raises { Refract::Visitor.new.visit_each(nil) }
	end

	test "visit each yields between nodes, skipping nil" do
		recorder = Recorder.new
		first, second, third = Refract::NilNode.new, Refract::SelfNode.new, Refract::TrueNode.new

		recorder.visit_each([first, nil, second, third, nil]) { recorder.visited << :separator }

		assert_equal recorder.visited, [first, :separator, second, :separator, third]
	end

	test "mutation visitor rebuilds an equivalent tree" do
		source = File.read(File.expand_path("../lib/refract/basic_visitor.rb", __dir__))
		tree = convert(source)
		result = Refract::MutationVisitor.new.visit(tree)

		assert_equal format(result), format(tree)
	end

	test "mutation visitor returns nil for nil" do
		assert_nil Refract::MutationVisitor.new.visit(nil)
	end

	test "mutation visitor rejects visit methods that do not return a node" do
		[nil, "baz"].each do |replacement|
			visitor = Class.new(Refract::MutationVisitor) do
				visit(Refract::CallNode) { |node| replacement }
			end

			error = assert_raises(TypeError) { visitor.new.visit(convert("foo")) }
			assert_equal error.message, "Visiting a Refract::CallNode returned #{replacement.inspect}, expected a Refract::Node."
		end
	end

	test "mutation visitor rejects around visit overrides that do not return the visited node" do
		visitor = Class.new(Refract::MutationVisitor) do
			def around_visit(node)
				yield(node)
				nil
			end
		end

		error = assert_raises(TypeError) { visitor.new.visit(convert("foo")) }
		assert_equal error.message, "Visiting a Refract::CallNode returned nil, expected a Refract::Node."
	end
end
