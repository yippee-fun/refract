# frozen_string_literal: true

KEYWORDS = %w[if unless else elsif end while until do begin rescue ensure case when in then return break next redo retry defined? not and or yield self nil true false super def class module alias undef __method__ BEGIN END].freeze
OPERATORS = %w[-> { } ( ) [ ] .. ... && || ! - + * ** / % == != =~ !~ < <= <=> << >> ~ ^ , ; = += -= ||= &&= ? : :: . &. => | & *a **a &b ->(x) |x| |x,y|].freeze
LITERALS = ["@a", "@@a", "$a", "$1", "A", "x", "y", "foo", "bar", "foo!", "bar?", "baz=", "1", "-1", "2.0", "1r", "2i", "?c", ":sym", ':"s"', '"s"', "'s'", "\"\#{x}\"", "%w[a]", "%i[a]", "/r/", "/\#{x}/", "`ls`", "<<~X\na\nX\n", "a:", "x:"].freeze
TOKENS = [*KEYWORDS, *OPERATORS, *LITERALS].map { |it| " #{it} " }.freeze

class FuzzTest < Quickdraw::Test
	fuzz "formatting any source Prism accepts keeps its meaning", string([" ", " ", "\n", "x", "1"], length: 0..14, dictionary: TOKENS) do |source|
		next unless Prism.parse(source).errors.empty?

		result = SemanticTree.round_trip(source)
		assert(result.errors.empty?) { "#{source.inspect} formats to:\n\n#{result.source}\n\n#{result.errors.map(&:message).join("\n")}" }
		next unless result.errors.empty?

		mismatch = mismatch(source, result.source)
		assert(mismatch.nil?) { "#{source.inspect} formats to:\n\n#{result.source}\n\n#{mismatch.inspect}" }
	end

	fuzz "formatted generated trees parse back to the same tree", TreeGenerator.program, cases: 50 do |tree|
		result = TreeShape.round_trip(tree)
		assert(result.errors.empty?) { TreeShape.report(tree, result) }
		assert(result.mismatch.nil?) { TreeShape.report(tree, result) }
	end

	test "the formatter's (x if true) around a regexp or range is not a mismatch" do
		refute mismatch("/r/ . !", "!(/r/ if true)")
		refute mismatch("(a..b).!", "!(a..b if true)")
		refute mismatch("!(1; /r/)", "!(1; (/r/ if true))")
		assert mismatch("!/r/", "!(/r/ if true)")
		assert mismatch("(1; /r/).!", "!(/r/ if true)")
	end

	def mismatch(source, formatted)
		original, regenerated = [source, formatted].map { |it| without_value_wrappers(SemanticTree.of(Prism.parse(it).value)) }
		SemanticTree.compare(original, regenerated)
	end

	# Without the formatter's `(x if true)`, a regexp or range in a condition parses
	# as a different node, so removing the wrapper can't hide a change of meaning.
	def without_value_wrappers(tree)
		case tree
		in [:if_node, [[:predicate, [:true_node, []]], [:statements, [:statements_node, [[:body, [[:regular_expression_node | :interpolated_regular_expression_node | :range_node, *] => value]]]]], [:subsequent, nil]]]
			without_value_wrappers(value)
		in Array
			tree.map { |it| without_value_wrappers(it) }
		else
			tree
		end
	end
end
