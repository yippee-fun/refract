# Refract

Refract lets you re-write Ruby at the AST level.

1. The `Converter` walks a concrete Prism syntax tree and produces an abstract Refract tree.
2. The `MutationVisitor` walks the Refract tree, allowing you to mutate existing nodes and insert new nodes.
3. Finally, the `Formatter` walks the Refract tree producing valid Ruby code.

## What the round trip preserves

Converting and formatting preserves the meaning of the code, not its layout. Comments, heredocs, `%w[]` and other literal syntaxes, and optional parentheses are normalised.

When formatting a `ProgramNode`, the `frozen_string_literal` and `encoding` magic comments are re-emitted. `shareable_constant_value` is re-emitted around each statement containing a constant write it applies to. These are not re-emitted when formatting a smaller node, so formatted fragments take on the settings of the file they are evaluated in.

`__LINE__` is formatted as the line number it had in the original source.

Not preserved:

- `__END__` and the data after it, so `DATA` is not defined.
- The encoding of string literals containing raw non-ASCII bytes in an `# encoding: ASCII-8BIT` file, because Prism reports such files as UTF-8.

Run `CORPUS=1 bundle exec qt test/corpus.test.rb` to round trip every Ruby file in the standard library and installed gems.
