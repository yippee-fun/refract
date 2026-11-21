# Refract

Refract lets you re-write Ruby at the AST level.

1. The `Converter` walks a concrete Prism syntax tree and produces an abstract Refract tree.
2. The `MutationVisitor` walks the Refract tree, allowing you to mutate existing nodes and insert new nodes.
3. Finally, the `Formatter` walks the Refract tree producing valid Ruby code.

```ruby
tree = Refract::Converter.new.visit(Prism.parse(source).value)
tree = MyMutationVisitor.new.visit(tree)
result = Refract::Formatter.new.format_node(tree)
result.source     # Ruby
result.source_map # the original line of each output line
```

## Nodes

Nodes are immutable. `node.copy(**changes)` builds a new node through the class's constructor, so it is validated and frozen like any other. A copy keeps the original's `prism_node`, so its `start_line`, and the source map entries for it, point at where it came from. Nodes built by hand have no `prism_node`.

The same node can appear in more than one place in a tree.

A `MutationVisitor`'s visit methods must return something that responds to `accept`, normally a node.

## Formatting

The formatter's output is not meant to look good, but it is meant to be valid Ruby that means exactly what the tree says, for any well-formed tree, including ones built or rearranged by hand. Operands are parenthesised wherever precedence or context could change their meaning, and ranges, regular expressions and flip-flops are written so they stay values or conditions as the tree says.

## What the round trip preserves

Converting and formatting preserves the meaning of the code, not its layout. Comments, heredocs, `%w[]` and other literal syntaxes, and optional parentheses are normalised.

When formatting a `ProgramNode`, the `frozen_string_literal` and `encoding` magic comments are re-emitted. `shareable_constant_value` is re-emitted around each statement containing a constant write it applies to. These are not re-emitted when formatting a smaller node, so formatted fragments take on the settings of the file they are evaluated in.

`__LINE__` is formatted as the line number it had in the original source.

Not preserved:

- `__END__` and the data after it, so `DATA` is not defined.
- The encoding of string literals containing raw non-ASCII bytes in an `# encoding: ASCII-8BIT` file, because Prism reports such files as UTF-8.

## Testing

```sh
bundle exec qd                                  # the suite, including property tests
CORPUS=1 bundle exec qd test/corpus.test.rb     # round trip the standard library and installed gems
CORPUS=rubygems bundle exec qd test/corpus.test.rb  # only files whose path matches
bundle exec qd fuzz test/fuzz.test.rb --timeout 10  # fuzz source round trips and generated trees
bundle exec qd --coverage                       # coverage report in .quickdraw/coverage/
bundle exec qd mutate lib                       # mutation testing, after a coverage run
```
