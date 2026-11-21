# frozen_string_literal: true

# Replaces every leaf it can with a uniquely named method call, so an output
# line can be traced back to the original nodes it prints. Patterns, hash keys
# and rescued exceptions keep theirs, as a call can't stand in for them.
class MarkerVisitor < Refract::MutationVisitor
	MARKER = /\bm\d+\b/
	LEAVES = [
		Refract::IntegerNode,
		Refract::FloatNode,
		Refract::StringNode,
		Refract::SymbolNode,
		Refract::NilNode,
		Refract::TrueNode,
		Refract::FalseNode,
		Refract::SelfNode,
		Refract::ConstantReadNode,
		Refract::InstanceVariableReadNode,
		Refract::LocalVariableReadNode,
	].freeze

	# The lines of each marker's located ancestors, any of which may claim the
	# output line it's printed on.
	def self.lines(node, ancestors = [], found = {})
		case node
		in Refract::CallNode[name: Symbol => name] if MARKER.match?(name)
			found[name.name] = [*ancestors, node].filter_map(&:start_line)
		in Refract::Node
			node.deconstruct_keys(nil).each_value { |it| lines(it, [*ancestors, node], found) }
		in Array
			node.each { |it| lines(it, ancestors, found) }
		else
			nil
		end

		found
	end

	# The lines of located nodes without markers, such as `return`, which can
	# claim a line without a marker showing.
	def self.unmarked_lines(node)
		case node
		in Refract::Node
			own = (node.start_line && lines(node).empty?) ? [node.start_line] : []
			[*own, *unmarked_lines(node.deconstruct_keys(nil).values)]
		in Array
			node.flat_map { |it| unmarked_lines(it) }
		else
			[]
		end
	end

	def initialize
		super
		@count = 0
	end

	LEAVES.each do |leaf|
		visit(leaf) { |_node| marker }
	end

	visit Refract::CallNode do |node|
		node.variable_call ? marker : super(node)
	end

	visit Refract::MatchPredicateNode do |node|
		node.copy(value: visit(node.value))
	end

	visit Refract::MatchRequiredNode do |node|
		node.copy(value: visit(node.value))
	end

	visit Refract::AssocNode do |node|
		node.copy(value: visit(node.value))
	end

	visit Refract::RescueNode do |node|
		node.copy(statements: visit(node.statements), subsequent: visit(node.subsequent))
	end

	private def marker
		Refract::CallNode.new(name: :"m#{@count += 1}", safe_navigation: false, variable_call: true, attribute_write: false)
	end
end

# Edits statements as the compiler does: duplicating them, copying them into
# both branches of a new if, and moving them into new blocks and modifiers.
class CopyingVisitor < Refract::MutationVisitor
	EDITS = %i[keep duplicate branches block modifier].freeze

	def initialize(edits)
		super()
		@edits = edits.cycle
	end

	visit Refract::StatementsNode do |node|
		node.copy(body: node.body.flat_map { |it| edit(visit(it)) })
	end

	private def edit(statement)
		case @edits.next
		in :keep then [statement]
		in :duplicate then [statement, statement]
		in :branches
			[Refract::IfNode.new(predicate: condition, statements: wrap(statement), subsequent: Refract::ElseNode.new(statements: wrap(statement)), inline: false)]
		in :block
			block = Refract::BlockNode.new(parameters: nil, body: wrap(statement))
			[Refract::CallNode.new(name: :tap, block:, safe_navigation: false, variable_call: false, attribute_write: false)]
		in :modifier
			[Refract::IfNode.new(predicate: condition, statements: wrap(statement), inline: true)]
		end
	end

	private def condition
		Refract::CallNode.new(name: :cond, safe_navigation: false, variable_call: true, attribute_write: false)
	end

	private def wrap(statement)
		Refract::StatementsNode.new(body: [statement])
	end
end

class PropertyTest < Quickdraw::Test
	test "formatted trees parse back to the same tree" do
		check(TreeGenerator.program, cases: 300) do |tree|
			result = TreeShape.round_trip(tree)
			assert(result.errors.empty?) { TreeShape.report(tree, result) }
			assert(result.mismatch.nil?) { TreeShape.report(tree, result) }
		end
	end

	test "copied and moved statements format to parseable code with a consistent source map" do
		check(TreeGenerator.program, array(one_of(*CopyingVisitor::EDITS), length: 1..8), cases: 100) do |tree, edits|
			original = Refract::Formatter.new.format_node(MarkerVisitor.new.visit(tree)).source
			parsed = Prism.parse(original)
			next unless parsed.errors.empty?

			program = Refract::Converter.new.visit(parsed.value)
			markers = MarkerVisitor.lines(program)
			unmarked = MarkerVisitor.unmarked_lines(program)
			result = Refract::Formatter.new.format_node(CopyingVisitor.new(edits).visit(program))
			errors = Prism.parse(result.source).errors.map(&:message)

			assert(errors.empty?) { "#{original}\n\nbecame\n\n#{result.source}\n\n#{errors.join("\n")}" }

			result.source.lines.each.with_index(1) do |line, number|
				mapped = result.source_map[number]
				marked = line.scan(MarkerVisitor::MARKER).flat_map { |it| markers.fetch(it) }

				if marked.empty?
					assert(mapped.nil? || mapped.between?(1, original.count("\n") + 1)) do
						"Line #{number} maps to #{mapped.inspect}, outside the original.\n\n#{original}\n\n#{result.source}"
					end
				else
					expected = (marked | unmarked).sort
					assert(expected.include?(mapped)) do
						"Line #{number} (#{line.strip}) maps to #{mapped.inspect}, expected one of #{expected}.\n\n#{original}\n\n#{result.source}"
					end
				end
			end
		end
	end
end
