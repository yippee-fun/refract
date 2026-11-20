# frozen_string_literal: true

class FormatterTest < Quickdraw::Test
	include Refract

	def format(node)
		Formatter.new.format_node(node).source
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

	# Formats a hand-built tree, parses the output and converts it back.
	def assert_tree(node)
		source = format(node)
		result = Prism.parse(source)

		assert(result.errors.empty?) { "#{source}\n#{result.errors.map(&:message).join("\n")}" }
		return unless result.errors.empty?

		regenerated = Converter.new.visit(result.value).statements
		assert(normalize(regenerated) == normalize(node)) do
			"#{source}\nexpected: #{normalize(node).inspect}\nactual:   #{normalize(regenerated).inspect}"
		end
	end

	# Ignores parentheses, single statement wrappers, the `nil; ` that keeps a
	# range or regexp out of a condition, and whether an `if` was a modifier.
	def normalize(node)
		case node
		when ParenthesesNode
			normalize(node.body)
		when StatementsNode
			case flatten(node.body)
			in [statement] then normalize(statement)
			in [NilNode, statement] then normalize(statement)
			in statements then [:statements, statements.map { |it| normalize(it) }]
			end
		when Node
			[node.type, (node.class.attributes - [:inline, :depth]).to_h { |name| [name, normalize(node.public_send(name))] }]
		when Array
			node.map { |it| normalize(it) }
		when nil, false
			false
		else
			node
		end
	end

	def flatten(body)
		body.flat_map { |it| (StatementsNode === it) ? flatten(it.body) : it }
	end

	def var(name) = CallNode.new(name:, variable_call: true)
	def int(value) = IntegerNode.new(value:)
	def sym(name) = SymbolNode.new(unescaped: name, quoted: false)
	def statements(*body) = StatementsNode.new(body:)
	def arguments(*arguments) = ArgumentsNode.new(arguments:)
	def call(name, *args, receiver: nil, **) = CallNode.new(name:, receiver:, arguments: (arguments(*args) unless args.empty?), **)
	def and_node(left, right, operator = "&&") = AndNode.new(left:, operator:, right:)
	def or_node(left, right, operator = "||") = OrNode.new(left:, operator:, right:)
	def range(left, right) = RangeNode.new(left:, right:, exclude_end: false)
	def flip_flop(left, right) = FlipFlopNode.new(left:, right:, exclude_end: false)
	def if_modifier(body, predicate) = IfNode.new(predicate:, statements: statements(body), inline: true)
	def if_node(predicate, *body, subsequent: nil) = IfNode.new(predicate:, statements: statements(*body), subsequent:, inline: false)
	def write(name, value) = LocalVariableWriteNode.new(name:, value:, depth: nil)
	def target(name) = LocalVariableTargetNode.new(name:, depth: nil)
	def regexp(source) = RegularExpressionNode.new(unescaped: source, ignore_case: false, multi_line: false, extended: false, once: false)
	def match_last_line(source) = MatchLastLineNode.new(unescaped: source, ignore_case: false, multi_line: false, extended: false, once: false)
	def in_block(node) = call(:foo, block: BlockNode.new(parameters: nil, body: statements(node)))
	def in_def(node) = DefNode.new(name: :m, receiver: nil, parameters: nil, body: statements(node))

	COMPOUND = {
		"and" => -> { and_node(var(:a), var(:b), "and") },
		"&&" => -> { and_node(var(:a), var(:b)) },
		"or" => -> { or_node(var(:a), var(:b), "or") },
		"modifier if" => -> { if_modifier(var(:b), var(:a)) },
		"modifier unless" => -> { UnlessNode.new(predicate: var(:a), statements: statements(var(:b)), else_clause: nil, inline: true) },
		"modifier while" => -> { WhileNode.new(predicate: var(:a), statements: statements(var(:b)), inline: true) },
		"modifier until" => -> { UntilNode.new(predicate: var(:a), statements: statements(var(:b)), inline: true) },
		"rescue modifier" => -> { RescueModifierNode.new(expression: var(:a), rescue_expression: var(:b)) },
		"in" => -> { MatchPredicateNode.new(value: var(:a), pattern: int(1)) },
		"write" => -> { write(:x, var(:a)) },
		"attribute write" => -> { call(:b=, var(:c), receiver: var(:a), attribute_write: true) },
		"multiple write" => -> { MultiWriteNode.new(lefts: [target(:p), target(:q)], rest: nil, rights: [], value: var(:r)) },
		"range" => -> { range(var(:a), var(:b)) },
		"endless range" => -> { range(var(:a), nil) },
		"statements" => -> { statements(var(:a), var(:b)) },
	}.freeze

	POSITIONS = {
		"call argument" => -> (v) { call(:foo, v) },
		"receiver" => -> (v) { call(:foo, receiver: v) },
		"safe navigation receiver" => -> (v) { call(:foo, receiver: v, safe_navigation: true) },
		"super argument" => -> (v) { in_def(SuperNode.new(arguments: arguments(v), block: nil)) },
		"yield argument" => -> (v) { in_def(YieldNode.new(arguments: arguments(v))) },
		"array element" => -> (v) { ArrayNode.new(elements: [v, int(1)]) },
		"hash key" => -> (v) { HashNode.new(elements: [AssocNode.new(key: v, value: int(1))]) },
		"hash value" => -> (v) { HashNode.new(elements: [AssocNode.new(key: sym("k"), value: v)]) },
		"keyword argument" => -> (v) { call(:foo, KeywordHashNode.new(elements: [AssocNode.new(key: sym("k"), value: v)])) },
		"splat" => -> (v) { ArrayNode.new(elements: [SplatNode.new(expression: v)]) },
		"block argument" => -> (v) { call(:foo, block: BlockArgumentNode.new(expression: v)) },
		"double splat" => -> (v) { HashNode.new(elements: [AssocSplatNode.new(value: v)]) },
		"when condition" => -> (v) { CaseNode.new(predicate: var(:x), conditions: [WhenNode.new(conditions: [v], statements: nil)], else_clause: nil) },
		"case predicate" => -> (v) { CaseNode.new(predicate: v, conditions: [WhenNode.new(conditions: [int(1)], statements: nil)], else_clause: nil) },
		"defined?" => -> (v) { DefinedNode.new(value: v) },
		"and left" => -> (v) { and_node(v, var(:z)) },
		"and right" => -> (v) { and_node(var(:z), v) },
		"or left" => -> (v) { or_node(v, var(:z)) },
		"or right" => -> (v) { or_node(var(:z), v, "or") },
		"range left" => -> (v) { range(v, var(:z)) },
		"range right" => -> (v) { range(var(:z), v) },
		"rescue modifier expression" => -> (v) { RescueModifierNode.new(expression: v, rescue_expression: var(:z)) },
		"rescue modifier rescue" => -> (v) { RescueModifierNode.new(expression: var(:z), rescue_expression: v) },
		"not" => -> (v) { call(:!, receiver: v) },
		"local write" => -> (v) { write(:w, v) },
		"instance variable write" => -> (v) { InstanceVariableWriteNode.new(name: :@w, value: v) },
		"global write" => -> (v) { GlobalVariableWriteNode.new(name: :$w, value: v) },
		"constant write" => -> (v) { ConstantWriteNode.new(name: :W, value: v) },
		"constant path write" => -> (v) { ConstantPathWriteNode.new(target: ConstantPathNode.new(parent: ConstantReadNode.new(name: :A), name: :W), value: v) },
		"operator write" => -> (v) { LocalVariableOperatorWriteNode.new(name: :w, value: v, binary_operator: :+, depth: 0) },
		"attribute write value" => -> (v) { call(:b=, v, receiver: var(:a), attribute_write: true) },
		"index write value" => -> (v) { call(:[]=, int(0), v, receiver: var(:a), attribute_write: true) },
		"index write receiver" => -> (v) { call(:[]=, int(0), int(1), receiver: v, attribute_write: true) },
		"index operator write receiver" => -> (v) { IndexOperatorWriteNode.new(receiver: v, arguments: arguments(int(0)), block: nil, binary_operator: :+, value: int(1)) },
		"call operator write receiver" => -> (v) { CallOperatorWriteNode.new(receiver: v, read_name: :b, binary_operator: :+, value: int(1)) },
		"multiple write value" => -> (v) { MultiWriteNode.new(lefts: [target(:p), target(:q)], rest: nil, rights: [], value: v) },
		"call target receiver" => -> (v) { MultiWriteNode.new(lefts: [CallTargetNode.new(receiver: v, name: :b=), target(:q)], rest: nil, rights: [], value: var(:r)) },
		"index target receiver" => -> (v) { MultiWriteNode.new(lefts: [IndexTargetNode.new(receiver: v, arguments: arguments(int(0)), block: nil), target(:q)], rest: nil, rights: [], value: var(:r)) },
		"constant path target parent" => -> (v) { MultiWriteNode.new(lefts: [ConstantPathTargetNode.new(parent: v, name: :C), target(:q)], rest: nil, rights: [], value: var(:r)) },
		"constant path parent" => -> (v) { ConstantPathNode.new(parent: v, name: :C) },
		"def receiver" => -> (v) { DefNode.new(name: :m, receiver: v, parameters: nil, body: nil) },
		"return" => -> (v) { ReturnNode.new(arguments: arguments(v)) },
		"break" => -> (v) { in_block(BreakNode.new(arguments: arguments(v))) },
		"next" => -> (v) { in_block(NextNode.new(arguments: arguments(v))) },
		"modifier body" => -> (v) { if_modifier(v, var(:z)) },
		"modifier predicate" => -> (v) { if_modifier(var(:z), v) },
		"while modifier predicate" => -> (v) { WhileNode.new(predicate: v, statements: statements(var(:z)), inline: true) },
		"if predicate" => -> (v) { if_node(v, var(:z)) },
		"elsif predicate" => -> (v) { if_node(var(:y), var(:z), subsequent: if_node(v, var(:z))) },
		"while predicate" => -> (v) { WhileNode.new(predicate: v, statements: statements(var(:z)), inline: false) },
		"for collection" => -> (v) { ForNode.new(index: target(:i), collection: v, statements: nil) },
		"optional parameter" => -> (v) { DefNode.new(name: :m, receiver: nil, parameters: ParametersNode.new(requireds: [], optionals: [OptionalParameterNode.new(name: :o, value: v)], rest: nil, posts: [], keywords: [], keyword_rest: nil, block: nil), body: nil) },
	}.freeze

	POSITIONS.each do |position, build|
		test "a hand-built compound node in #{position} position keeps its meaning" do
			COMPOUND.each_value { |value| assert_tree(instance_exec(instance_exec(&value), &build)) }
		end
	end

	test "precedence examples" do
		assert_equal format(and_node(or_node(var(:a), var(:b)), var(:c))), "(a || b) && c"
		assert_equal format(write(:x, and_node(var(:a), var(:b), "and"))), "x = (a and b)"
		assert_equal format(call(:foo, if_modifier(var(:b), var(:a)))), "foo((b if a))"
		assert_equal format(range(range(var(:a), var(:b)), var(:c))), "(a..b)..c"
		assert_equal format(if_modifier(var(:d), if_modifier(var(:b), var(:a)))), "d if (b if a)"
	end

	test "modifier bodies with several statements are parenthesized" do
		assert_tree(if_modifier(statements(var(:a), var(:b)), var(:c)))
		assert_tree(statements(write(:x, int(1)), call(:foo, statements(write(:x, int(2)), LocalVariableReadNode.new(name: :x, depth: nil)))))
	end

	test "a modifier if or unless with an else is written in full" do
		node = IfNode.new(predicate: var(:a), statements: statements(var(:b)), subsequent: ElseNode.new(statements: statements(var(:c))), inline: true)
		assert_tree(node)

		node = UnlessNode.new(predicate: var(:a), statements: statements(var(:b)), else_clause: ElseNode.new(statements: statements(var(:c))), inline: true)
		assert_tree(node)

		assert_tree(if_node(var(:a), var(:b), subsequent: if_modifier(var(:c), var(:d))))
	end

	test "rationals with repeating decimals stay exact, including imaginary ones" do
		assert_equal format(RationalNode.new(numerator: 1, denominator: 3)), "(1r/3)"
		assert_equal format(ImaginaryNode.new(numeric: RationalNode.new(numerator: -1, denominator: 3))), "(-1ri/3)"
		assert_equal format(ImaginaryNode.new(numeric: RationalNode.new(numerator: 5, denominator: 2))), "2.5ri"
		assert_equal eval(format(ImaginaryNode.new(numeric: RationalNode.new(numerator: 1, denominator: 3)))), Complex(0, 1/3r)
	end

	test "a range or regexp in a condition stays a range or regexp" do
		[
			if_node(range(var(:a), var(:b)), var(:c)),
			if_node(regexp("a"), var(:c)),
			if_modifier(var(:c), range(var(:a), var(:b))),
			if_node(and_node(var(:x), range(var(:a), var(:b))), var(:c)),
			if_node(or_node(regexp("a"), var(:x)), var(:c)),
			if_node(ParenthesesNode.new(body: statements(range(var(:a), var(:b)))), var(:c)),
			WhileNode.new(predicate: range(var(:a), nil), statements: statements(var(:c)), inline: false),
			call(:!, receiver: range(var(:a), var(:b))),
			call(:!, receiver: regexp("a")),
			if_node(flip_flop(range(var(:a), var(:b)), regexp("c")), var(:d)),
			if_node(BeginNode.new(statements: statements(regexp("a")), rescue_clause: nil, else_clause: nil, ensure_clause: nil), var(:c)),
		].each { |node| assert_tree(node) }

		assert_round_trip "if begin /a/ end then b end"
	end

	test "a flip-flop or match-last-line outside a condition is put in one" do
		assert_equal format(write(:x, flip_flop(var(:a), var(:b)))), "x = (((a..b) ? true : false))"
		assert_equal format(write(:x, match_last_line("a"))), "x = /a/.=~($_)"
		assert_equal format(and_node(var(:x), match_last_line("a"))), "x && /a/.=~($_)"

		interpolated = InterpolatedMatchLastLineNode.new(parts: [StringNode.new(unescaped: "a"), EmbeddedStatementsNode.new(statements: statements(var(:b)))], ignore_case: false, multi_line: false, extended: false, once: false)
		assert_equal format(write(:x, interpolated)), "x = /a\#{b}/.=~($_)"
		assert_equal format(if_node(interpolated, var(:c))), "if /a\#{b}/\n\tc\nend"

		assert_tree(if_node(flip_flop(var(:a), var(:b)), var(:c)))
		assert_tree(if_node(and_node(match_last_line("a"), flip_flop(match_last_line("b"), nil)), var(:c)))
		assert_tree(call(:!, receiver: flip_flop(var(:a), var(:b))))
		assert_tree(if_node(call(:!, receiver: match_last_line("a")), var(:c)))
	end

	test "a receiverless call without arguments is not read as a local variable" do
		node = statements(write(:x, int(1)), call(:x))
		assert_equal format(node), "x = 1\nx()"
		assert_tree(node)
	end

	test "call targets keep safe navigation" do
		assert_round_trip "for a&.b in c; end"
		assert_round_trip "begin; rescue => a&.b; end"
		assert_round_trip "for a.b in c; end"
	end

	test "top level constant path targets keep their colons" do
		assert_round_trip "::A, b = c"
		assert_round_trip "::A::B, c = d"
		assert_equal format(ConstantPathTargetNode.new(parent: nil, name: :A)), "::A"
	end

	test "endless ranges and flip-flops do not run into the next line" do
		assert_round_trip "a = 1..; b"
		assert_round_trip "1..; b"
		assert_round_trip "case x; in 1.. then y; end"
		assert_round_trip "case x; in 1 | 2.. then y; end"
		assert_round_trip "case x; when 1.. then y; end"
		assert_round_trip "for a in 1..; end"
		assert_round_trip "while a..; b; end"
		assert_round_trip "until 1..; end"
		assert_round_trip "x in 1..; y"
		assert_round_trip "x => 1.. | 2..; y"
		assert_round_trip "foo(1..)\nbar"
	end

	test "not keeps its operand in a condition" do
		assert_round_trip "x = !/foo/"
		assert_round_trip "x = not /foo/"
		assert_round_trip "if !(a..b); end"
		assert_round_trip "x = !(a..b)"
		assert_round_trip "x = !a"
		assert_round_trip "x = (!a).b"
		assert_equal format(Converter.new.visit(Prism.parse("not x").value)), "!x"
	end

	test "not leaves a primary operand bare so a private ! stays callable on self" do
		assert_round_trip "!self"
		assert_round_trip "not self"
		assert_round_trip "x = !a.b"
		assert_tree(call(:!, receiver: if_node(var(:a), var(:b))))
		assert_tree(call(:!, receiver: call(:!, receiver: var(:a))))
		assert_equal format(call(:!, receiver: write(:x, var(:a)))), "!(x = a)"
	end

	test "a block-form if at the start of a return, break, next or rescue value is parenthesized" do
		receiver = IfNode.new(predicate: StringNode.new(unescaped: "s"), statements: nil, inline: false)
		assert_tree(ReturnNode.new(arguments: arguments(call(:-@, receiver:))))
		assert_tree(in_block(NextNode.new(arguments: arguments(int(1), call(:foo, receiver: ConstantPathNode.new(parent: receiver, name: :C))))))
		assert_tree(RescueModifierNode.new(expression: var(:a), rescue_expression: call(:foo, receiver:)))
		assert_round_trip "return a ? b : c"
		assert_round_trip "begin\nrescue (a ? B : C).d\nend"
	end

	test "embedded variables are not extended by the text after them" do
		assert_round_trip "@x = 1; \"\#@x\" \"y\""
		assert_round_trip "$x = 1; \"\#$x\" \"_\""
		assert_round_trip "\"\#$1\" \"2\""
		assert_round_trip "@x = 1; \"\#@x\" \"é\""
		assert_round_trip "@x = 1; \"\#@x\" \" y\""
		assert_equal format(Converter.new.visit(Prism.parse("/a\#$&2}/").value)), "/a\#$&2}/"
		assert_round_trip "\"\#$-w\" \"x\""

		ivar = EmbeddedVariableNode.new(variable: InstanceVariableReadNode.new(name: :@x))
		string = StringNode.new(unescaped: "y")
		assert_tree(InterpolatedSymbolNode.new(parts: [ivar, string]))
		assert_equal format(InterpolatedRegularExpressionNode.new(parts: [ivar, string], ignore_case: false, multi_line: false, extended: false, once: false)), "/\#@x\\x79/"
	end

	test "word arrays in patterns stay values" do
		assert_round_trip "case x; in %w[a b]; end"
		assert_round_trip "case x; in %i[a b]; end"
		assert_round_trip "case x; in %W[a\#{1}b c\\ d \\] \\\\]; end"
		assert_round_trip "case x; in %I[a\#{1}b c]; end"
		assert_round_trip "case x; in %w[]; end"
		assert_round_trip "x in %w[a]"
		assert_round_trip "case x; in [%w[a], 1] | {a: %i[b]}; end"
		assert_round_trip "x => ..%w[a]"
		assert_round_trip "[\"b\"] in %w[a]..%w[c]"
		assert_round_trip "case x; in %i[a]..%i[b]; end"
		assert_round_trip "case x; in %w[a b] => y; end"
	end

	test "arrays and hashes that are not word arrays are pinned in patterns" do
		node = MatchPredicateNode.new(value: var(:x), pattern: ArrayNode.new(elements: [int(1)]))
		assert_equal format(node), "x in ^([\n\t1\n])"

		node = MatchPredicateNode.new(value: var(:x), pattern: ArrayNode.new(elements: [StringNode.new(unescaped: "")]))
		assert_equal format(node), "x in ^([\n\t\"\"\n])"

		node = MatchPredicateNode.new(value: var(:x), pattern: HashNode.new(elements: [AssocNode.new(key: sym("a"), value: int(1))]))
		assert_equal format(node), "x in ^({\n\ta: 1\n})"
	end

	test "arrays in parenthesized, statements or guarded patterns are pinned" do
		array = ArrayNode.new(elements: [int(1)])
		match = -> (pattern) { format(MatchPredicateNode.new(value: var(:x), pattern:)) }

		assert_equal match.(ParenthesesNode.new(body: statements(array))), "x in (^([\n\t1\n]))"
		assert_equal match.(ParenthesesNode.new(body: array)), "x in (^([\n\t1\n]))"
		assert_equal match.(statements(array)), "x in ^([\n\t1\n])"
		assert_tree(CaseMatchNode.new(predicate: int(3), conditions: [InNode.new(pattern: statements(range(int(1), nil)), statements: statements(int(42)))], else_clause: nil))
		assert_equal format(CaseMatchNode.new(predicate: var(:x), conditions: [InNode.new(pattern: if_modifier(array, var(:y)), statements: nil)], else_clause: nil)), "case x\nin ^([\n\t1\n]) if y\nend"
		assert_equal format(CaseMatchNode.new(predicate: var(:x), conditions: [InNode.new(pattern: if_modifier(int(2), array), statements: nil)], else_clause: nil)), "case x\nin 2 if [\n\t1\n]\nend"
	end

	test "nested multiple targets in a for loop keep their parentheses" do
		assert_round_trip "for ((a,b)) in [[1,2]]; end"
		assert_round_trip "for (a, b), c in d; end"
		assert_round_trip "for a, b in c; end"
		assert_round_trip "for (a, b) in c; end"
		assert_round_trip "((a, b)) = [[1, 2]]"
		assert_round_trip "((a, b)), c = d"
		assert_round_trip "(a, b), c = d"
	end

	test "a rational without an exact decimal is pinned in a pattern" do
		value = RationalNode.new(numerator: 1, denominator: 3)
		assert_equal format(MatchPredicateNode.new(value:, pattern: value.copy)), "(1r/3) in ^((1r/3))"
	end

	test "a comment in an extended regexp stays a comment" do
		source = format(Converter.new.visit(Prism.parse("%r{a#$}x").value))
		assert_equal source, "/a#\\$/x"
		assert_equal eval(source).match?("xa"), true
		assert_equal eval(source).match?("a#"), true

		assert_equal format(regexp('[#@a]').copy(extended: true)), "/[#\\@a]/x"
		assert_equal format(regexp('[#@a]')), '/[\#@a]/'
	end

	test "quoted shorthand keys in hash patterns" do
		assert_round_trip "case x; in {\"if\":}; end"
		assert_round_trip "case x; in {\"a\":}; end"
		assert_round_trip "case x; in {a:}; end"
	end

	test "constant writes with different shareable_constant_value settings in one statement" do
		assert_round_trip "[A = [],\n# shareable_constant_value: literal\nB = []]"
		assert_round_trip "# shareable_constant_value: literal\n[A = [],\n# shareable_constant_value: none\nB = []]"
		assert_round_trip "# shareable_constant_value: literal\nA = [B = 1,\n# shareable_constant_value: none\nC = []]\nD = []"
		assert_round_trip "foo(A = 1,\n# shareable_constant_value: experimental_everything\nB = [])\nC = []"
	end

	test "__LINE__ at the end of a flip-flop is not compared with $." do
		assert_equal format(Converter.new.visit(Prism.parse("if __LINE__..false; end").value)), "if ((nil; 1)..false)\nend"
		assert_round_trip "x = __LINE__..false"
		assert_round_trip "if __LINE__; end"
	end

	test "symbol quoted is a boolean" do
		symbols = [":a", ':"a"', "%s(a)", "%i[a]", "{a: 1}", '{"a": 1}'].map do |source|
			case Converter.new.visit(Prism.parse(source).value).statements.body.first
			in ArrayNode[elements: [symbol]] then symbol
			in HashNode[elements: [AssocNode[key: symbol]]] then symbol
			in symbol then symbol
			end
		end

		assert_equal symbols.map(&:quoted), [false, true, true, false, false, true]
	end

	test "formatting twice with one formatter gives the same result" do
		formatter = Formatter.new(starting_line: 3)
		first = formatter.format_node(int(1))
		second = formatter.format_node(int(2))

		assert_equal first.source, "1"
		assert_equal second.source, "2"
		assert_equal second.source_map, first.source_map
	end

	test "a missing node raises" do
		node = Converter.new.visit(Prism.parse("x = ").value)
		assert_raises(ArgumentError) { format(node) }
	end

	test "match write targets must match the named captures" do
		program = Converter.new.visit(Prism.parse("/(?<a>.)(?<b>.)/ =~ x").value)
		match_write = program.statements.body.first
		assert_equal format(program), "/(?<a>.)(?<b>.)/ =~ x"

		renamed = match_write.copy(targets: [target(:a), target(:c)])
		assert_raises(ArgumentError) { format(renamed) }
		assert_raises(ArgumentError) { format(match_write.copy(targets: [target(:a)])) }
		assert_raises(ArgumentError) { format(match_write.copy(call: call(:=~, var(:x), receiver: regexp(".")))) }

		assert_round_trip "def f(if:) = /(?<if>.)/ =~ x"
	end

	test "floats built from values" do
		assert_equal format(FloatNode.new(value: 1.5)), "1.5"
		assert_equal format(FloatNode.new(value: Float::NAN)), "::Float::NAN"
		assert_equal format(FloatNode.new(value: Float::INFINITY)), "::Float::INFINITY"
		assert_equal format(call(:abs, receiver: FloatNode.new(value: -Float::INFINITY))), "(-::Float::INFINITY).abs"
	end

	test "nil child lists format like empty ones" do
		hash = HashNode.new(elements: [])
		block = BlockNode.new(parameters: BlockParametersNode.new(parameters: nil, locals: []), body: nil)
		rescue_clause = RescueNode.new(exceptions: [], reference: nil, statements: nil, subsequent: nil)
		begin_node = BeginNode.new(statements: nil, rescue_clause:, else_clause: nil, ensure_clause: nil)

		assert_equal format(hash.copy(elements: nil)), format(hash)
		assert_equal format(call(:foo, block: block.copy(parameters: block.parameters.copy(locals: nil)))), format(call(:foo, block:))
		assert_equal format(begin_node.copy(rescue_clause: rescue_clause.copy(exceptions: nil))), format(begin_node)
	end

	test "a safe navigation index write keeps method syntax" do
		assert_equal format(call(:[]=, int(0), int(1), receiver: var(:a), attribute_write: true, safe_navigation: true)), "a&.[]=(0, 1)"
	end

	test "an implicit hash value that is not a shorthand is written out" do
		node = HashNode.new(elements: [AssocNode.new(key: sym("a"), value: ImplicitNode.new(value: int(1)))])
		assert_equal format(node), "{\n\ta: 1\n}"
	end

	test "regexps and interpolated strings keep bytes that are invalid in their encoding" do
		bytes = "a\xFFb".dup.force_encoding(Encoding::UTF_8)
		embedded = EmbeddedStatementsNode.new(statements: statements(int(1)))
		variable = EmbeddedVariableNode.new(variable: InstanceVariableReadNode.new(name: :@x))

		assert_equal eval(format(regexp(bytes))).source.b, "a\xFFb".b
		assert_equal eval(format(InterpolatedStringNode.new(parts: [StringNode.new(unescaped: bytes), embedded]))).b, "a\xFFb1".b
		assert_equal format(InterpolatedStringNode.new(parts: [variable, StringNode.new(unescaped: bytes[1..])])), "\"\#@x\\xFFb\""
		assert_equal format(sym("a\xFF".dup.force_encoding(Encoding::UTF_8))), ":\"a\\xFF\""
		assert_equal format(SymbolNode.new(unescaped: "\"\xFF".dup.force_encoding(Encoding::UTF_8), quoted: true)), ":\"\\\"\\xFF\""
	end

	test "non-ASCII regexps and strings in one tree keep their encoding" do
		assert_equal format(statements(StringNode.new(unescaped: "é"), regexp("é"))), "\"é\"\n/é/"
	end

	test "strings in another encoding are written as bytes" do
		assert_equal format(StringNode.new(unescaped: "é".encode(Encoding::ISO_8859_1))), "\"\\xE9\""
	end

	test "a shareable constant write on its own or inside an expression" do
		write = ShareableConstantNode.new(value: :literal, write: ConstantWriteNode.new(name: :A, value: ArrayNode.new(elements: [])))

		assert_equal format(write), "# shareable_constant_value: literal\nA = [\n\t\n]\n# shareable_constant_value: none"
		assert_equal format(ArrayNode.new(elements: [write])), "[\n\t((\n\t\t# shareable_constant_value: literal\n\t\tA = [\n\t\t\t\n\t\t]\n\t\t# shareable_constant_value: none\n\t))\n]"
	end

	test "constant writes nested in a shareable constant write keep their own settings" do
		copy = ShareableConstantNode.new(value: :experimental_copy, write: ConstantWriteNode.new(name: :C, value: ArrayNode.new(elements: [])))
		body = BeginNode.new(statements: statements(ConstantWriteNode.new(name: :B, value: copy)), rescue_clause: nil, else_clause: nil, ensure_clause: nil)

		assert_tree(ShareableConstantNode.new(value: :literal, write: ConstantWriteNode.new(name: :A, value: body)))
	end

	test "nodes that write nothing get no separator" do
		assert_equal format(SuperNode.new(arguments:, block: BlockArgumentNode.new(expression: var(:b)))), "super(&b)"
	end

	test "nil entries in child lists are skipped" do
		assert_equal format(ArrayNode.new(elements: [int(1), nil, int(2)])), "[\n\t1,\n\t2\n]"
	end

	test "an implicit call value is only a shorthand without a receiver, arguments or block" do
		implicit = -> (value) { format(HashNode.new(elements: [AssocNode.new(key: sym("a"), value: ImplicitNode.new(value:))])) }

		assert_equal implicit.(call(:a)), "{\n\ta:\n}"
		assert_equal implicit.(call(:b)), "{\n\ta: b()\n}"
		assert_equal implicit.(call(:a, receiver: var(:x))), "{\n\ta: x.a\n}"
		assert_equal implicit.(call(:a, int(1))), "{\n\ta: a(1)\n}"
		assert_equal implicit.(call(:a, block: BlockNode.new(parameters: nil, body: nil))), "{\n\ta: a {\n\t\t\n\t}\n}"
	end

	test "only a value that starts with a block-form condition is parenthesized after return" do
		condition = IfNode.new(predicate: StringNode.new(unescaped: "s"), statements: nil, inline: false)

		assert_equal format(ReturnNode.new(arguments: arguments(call(:!, receiver: condition)))), "return !if \"s\"\nend"
		assert_equal format(ReturnNode.new(arguments: arguments(ConstantPathNode.new(parent: condition, name: :C)))), "return (if \"s\"\nend::C)"
	end

	test "a flip-flop formatted on its own is a value" do
		assert_equal format(flip_flop(var(:a), var(:b))), "((a..b) ? true : false)"
	end

	test "a regexp alone in a statements predicate is a condition" do
		assert_equal format(if_node(statements(regexp("a")), var(:c))), "if (\n\t(nil; /a/)\n)\n\tc\nend"
		assert_equal format(if_node(statements(var(:x), regexp("a")), var(:c))), "if (\n\tx\n\t/a/\n)\n\tc\nend"
	end

	test "arrays in patterns are word lists only when every element is a word" do
		pattern = -> (*elements) { format(MatchPredicateNode.new(value: var(:x), pattern: ArrayNode.new(elements:))) }
		empty = StringNode.new(unescaped: "")

		assert_equal pattern.(StringNode.new(unescaped: "a"), int(1)), "x in ^([\n\t\"a\",\n\t1\n])"
		assert_equal pattern.(sym("a"), int(1)), "x in ^([\n\t:a,\n\t1\n])"
		assert_equal pattern.(InterpolatedStringNode.new(parts: [empty])), "x in ^([\n\t\"\"\n])"
		assert_equal pattern.(InterpolatedStringNode.new(parts: [empty, EmbeddedStatementsNode.new(statements: statements(var(:y)))])), "x in %W[\#{y}]"
	end
end
