# Refract

Refract lets you re-write Ruby at the AST level.

1. The `Converter` walks a concrete Prism syntax tree and produces an abstract Refract tree.
2. The `MutationVisitor` walks the Refract tree, allowing you to mutate existing nodes and insert new nodes.
3. Finally, the `Formatter` walks the Refract tree producing valid Ruby code.
