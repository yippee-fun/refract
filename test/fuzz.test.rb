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
		assert(result.mismatch.nil?) { "#{source.inspect} formats to:\n\n#{result.source}\n\n#{result.mismatch.inspect}" }
	end

	fuzz "formatted generated trees parse back to the same tree", TreeGenerator.program, cases: 50 do |tree|
		result = TreeShape.round_trip(tree)
		assert(result.errors.empty?) { TreeShape.report(tree, result) }
		assert(result.mismatch.nil?) { TreeShape.report(tree, result) }
	end
end
