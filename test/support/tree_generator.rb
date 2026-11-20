# frozen_string_literal: true

# Draws random well-formed Refract trees, built by hand as a compiler would:
# no ParenthesesNode, and StatementsNode wherever a value is wanted.
#
# Locals are only read after a statement that writes them, so they mean the
# same wherever the formatter puts them. FlipFlopNode only appears where Ruby
# reads a condition (including any operand of `!`), and RangeNode only where
# it doesn't. Jumps and `=>` only appear where their value isn't used.
class TreeGenerator
	LOCALS = %i[a b c].freeze
	INSTANCE_VARIABLES = %i[@a @b].freeze
	PARAMETERS = %i[x y].freeze
	FUNCTIONS = %i[foo bar].freeze
	METHODS = %i[baz qux].freeze
	BINARY_OPERATORS = %i[+ - * ** == != < <=> << & | %].freeze
	UNARY_OPERATORS = %i[! -@ +@ ~].freeze
	LOGICAL_OPERATORS = [[Refract::AndNode, "&&"], [Refract::AndNode, "and"], [Refract::OrNode, "||"], [Refract::OrNode, "or"]].freeze
	LEAVES = %i[integer nil local function float string symbol true false self instance_variable constant].freeze
	KINDS = %i[leaf call binary unary logical write if unless loop rescue_modifier array hash defined statements begin case match_predicate lambda multi_write attribute_write index].freeze

	# Where an expression is: the locals it may read and assign, whether Ruby
	# reads it as a condition, whether its value is used, and whether break and
	# next may jump. In a block, only locals declared before it are assigned, so
	# no assignment's scope depends on where the formatter puts it.
	Position = Data.define(:locals, :assignable, :condition, :value, :loop) do
		def operand = with(condition: false, value: true)
		def predicate = with(condition: true, value: true)
		def body = with(condition: false)
	end

	def self.program(depth: 3)
		Quickdraw::Generator.new { |choices| new(choices).program(depth) }
	end

	# Every local a node assigns that's visible after it.
	def self.locals_written(value)
		case value
		in Refract::BlockNode | Refract::LambdaNode then []
		in Refract::LocalVariableWriteNode | Refract::LocalVariableTargetNode then [value.name, *locals_written(value.deconstruct_keys(nil).values)]
		in Refract::Node then locals_written(value.deconstruct_keys(nil).values)
		in Array then value.flat_map { |element| locals_written(element) }
		else []
		end
	end

	def initialize(choices)
		@choices = choices
	end

	def program(depth)
		top = Position.new(locals: [], assignable: LOCALS, condition: false, value: false, loop: false)
		Refract::ProgramNode.new(statements: statements(depth, top), encoding: Encoding::UTF_8)
	end

	private def statements(depth, position, length: 1..3)
		count = between(length)
		locals = position.locals

		body = Array.new(count) do |index|
			last = index == count - 1
			statement = expression(depth, position.with(locals:, condition: position.condition && count == 1, value: position.value && last))
			locals |= TreeGenerator.locals_written(statement)
			statement
		end

		Refract::StatementsNode.new(body:)
	end

	private def expression(depth, position)
		@choices.span do
			next leaf(position) if depth.zero?

			kinds = [*KINDS, position.condition ? :flip_flop : :range]
			kinds.push(:match_required, :jump) unless position.value

			build(choose(kinds), depth - 1, position)
		end
	end

	private def build(kind, depth, position)
		case kind
		in :leaf then leaf(position)
		in :call then call(depth, position)
		in :binary
			send_call(expression(depth, position.operand), choose(BINARY_OPERATORS), arguments: arguments([expression(depth, position.operand)]))
		in :unary
			operator = choose(UNARY_OPERATORS)
			send_call(expression(depth, (operator == :!) ? position.predicate : position.operand), operator)
		in :logical
			node_class, operator = choose(LOGICAL_OPERATORS)
			node_class.new(left: expression(depth, position.with(value: true)), operator:, right: expression(depth, position.with(value: true)))
		in :write then write(depth, position)
		in :if then if_node(depth, position)
		in :unless
			predicate = expression(depth, position.predicate)
			body = optional { statements(depth, position.body) }
			else_clause = optional { Refract::ElseNode.new(statements: statements(depth, position.body)) }
			Refract::UnlessNode.new(predicate:, statements: body, else_clause:, inline: inline?(body, else_clause))
		in :loop
			predicate = expression(depth, position.predicate)
			body = optional { statements(depth, position.with(condition: false, value: false, loop: true)) }
			choose([Refract::WhileNode, Refract::UntilNode]).new(predicate:, statements: body, inline: inline?(body, nil))
		in :rescue_modifier
			Refract::RescueModifierNode.new(expression: expression(depth, position.operand), rescue_expression: expression(depth, position.operand))
		in :array
			Refract::ArrayNode.new(elements: several(0..3) { argument(depth, position) })
		in :hash
			Refract::HashNode.new(elements: several(0..2) { hash_element(depth, position) })
		in :defined then Refract::DefinedNode.new(value: expression(depth, position.operand))
		in :statements then statements(depth, position, length: 2..3)
		in :begin then begin_node(depth, position)
		in :case then case_node(depth, position)
		in :match_predicate
			Refract::MatchPredicateNode.new(value: expression(depth, position.operand), pattern: pattern(position))
		in :match_required
			Refract::MatchRequiredNode.new(value: expression(depth, position.operand), pattern: pattern(position))
		in :lambda
			parameters = block_parameters(position)
			Refract::LambdaNode.new(parameters:, body: optional { statements(depth, block_body(position, parameters)) })
		in :multi_write then multi_write(depth, position)
		in :attribute_write
			name = :"#{choose(METHODS)}="
			send_call(expression(depth, position.operand), name, arguments: arguments([expression(depth, position.operand)]), safe_navigation: boolean, attribute_write: true)
		in :index
			send_call(expression(depth, position.operand), :[], arguments: arguments(several(1..2) { argument(depth, position) }))
		in :range
			left, right = choose([[true, true], [true, false], [false, true]]).map { |present| expression(depth, position.operand) if present }
			Refract::RangeNode.new(left:, right:, exclude_end: boolean)
		in :flip_flop
			Refract::FlipFlopNode.new(left: expression(depth, position.predicate), right: expression(depth, position.predicate), exclude_end: boolean)
		in :jump then jump(depth, position)
		end
	end

	private def leaf(position)
		case choose(position.locals.empty? ? LEAVES - [:local] : LEAVES)
		in :integer then Refract::IntegerNode.new(value: choose([1, 0, 2, -1, -2]))
		in :nil then Refract::NilNode.new
		in :local then Refract::LocalVariableReadNode.new(name: choose(position.locals))
		in :function then send_call(nil, choose(FUNCTIONS), variable_call: true)
		in :float then Refract::FloatNode.new(value: choose(%w[1.5 -0.5]))
		in :string then Refract::StringNode.new(unescaped: "s")
		in :symbol then Refract::SymbolNode.new(unescaped: "sym", quoted: nil)
		in :true then Refract::TrueNode.new
		in :false then Refract::FalseNode.new
		in :self then Refract::SelfNode.new
		in :instance_variable then Refract::InstanceVariableReadNode.new(name: choose(INSTANCE_VARIABLES))
		in :constant then Refract::ConstantReadNode.new(name: :Integer)
		end
	end

	private def call(depth, position)
		case choose(%i[function method])
		in :function
			args = several(0..2) { argument(depth, position) }
			block = block(depth, position) if args.empty? || boolean
			send_call(nil, choose(FUNCTIONS), arguments: arguments(args), block:)
		in :method
			receiver = expression(depth, position.operand)
			args = several(0..2) { argument(depth, position) }
			send_call(receiver, choose(METHODS), arguments: arguments(args), block: optional { block(depth, position) }, safe_navigation: boolean)
		end
	end

	private def write(depth, position)
		value = expression(depth, position.operand)

		case choose(position.assignable.empty? ? %i[instance_variable] : %i[local instance_variable])
		in :local then Refract::LocalVariableWriteNode.new(name: choose(position.assignable), value:)
		in :instance_variable then Refract::InstanceVariableWriteNode.new(name: choose(INSTANCE_VARIABLES), value:)
		end
	end

	private def if_node(depth, position, chained: false)
		predicate = expression(depth, position.predicate)
		body = optional { statements(depth, position.body) }

		subsequent = case choose(%i[none else elsif])
		in :none then nil
		in :else then Refract::ElseNode.new(statements: statements(depth, position.body))
		in :elsif then if_node(depth, position, chained: true)
		end

		Refract::IfNode.new(predicate:, statements: body, subsequent:, inline: !chained && inline?(body, subsequent))
	end

	private def begin_node(depth, position)
		body = statements(depth, position, length: 1..2)
		rescue_clause = optional do
			exceptions = optional { [Refract::ConstantReadNode.new(name: :StandardError)] } || []
			Refract::RescueNode.new(exceptions:, reference: nil, statements: optional { statements(depth, position.body) }, subsequent: nil)
		end
		else_clause = (optional { Refract::ElseNode.new(statements: statements(depth, position.body)) } if rescue_clause)
		ensure_clause = optional { Refract::EnsureNode.new(statements: statements(depth, position.body)) }

		Refract::BeginNode.new(statements: body, rescue_clause:, else_clause:, ensure_clause:)
	end

	private def case_node(depth, position)
		predicate = optional { expression(depth, position.operand) }
		conditions = several(1..2) do
			Refract::WhenNode.new(conditions: several(1..2) { argument(depth, position) }, statements: optional { statements(depth, position.body) })
		end
		else_clause = optional { Refract::ElseNode.new(statements: statements(depth, position.body)) }

		Refract::CaseNode.new(predicate:, conditions:, else_clause:)
	end

	private def multi_write(depth, position)
		lefts = several(1..2) { target(position) }
		rest = (Refract::SplatNode.new(expression: target(position)) if lefts.one? || boolean)
		rights = rest ? several(0..1) { target(position) } : []
		value = case choose(%i[single list])
		in :single then expression(depth, position.operand)
		in :list then Refract::ArrayNode.new(elements: several(2..3) { argument(depth, position) })
		end

		Refract::MultiWriteNode.new(lefts:, rest:, rights:, value:)
	end

	private def jump(depth, position)
		values = several(0..2) { argument(depth, position) }
		kinds = position.loop ? [Refract::ReturnNode, Refract::BreakNode, Refract::NextNode] : [Refract::ReturnNode]
		choose(kinds).new(arguments: arguments(values))
	end

	private def block(depth, position)
		parameters = block_parameters(position)
		Refract::BlockNode.new(parameters:, body: optional { statements(depth, block_body(position, parameters)) })
	end

	private def block_parameters(position)
		names = PARAMETERS - position.locals
		return if names.empty?

		optional do
			requireds = names.take(between(1..2)).map { |name| Refract::RequiredParameterNode.new(name:) }
			parameters = Refract::ParametersNode.new(requireds:, optionals: [], rest: nil, posts: [], keywords: [], keyword_rest: nil, block: nil)
			Refract::BlockParametersNode.new(parameters:, locals: [])
		end
	end

	private def block_body(position, parameters)
		locals = position.locals | (parameters ? parameters.parameters.requireds.map(&:name) : [])
		position.with(locals:, assignable: locals, condition: false, value: false, loop: true)
	end

	private def argument(depth, position)
		value = expression(depth, position.operand)
		boolean ? Refract::SplatNode.new(expression: value) : value
	end

	private def hash_element(depth, position)
		value = expression(depth, position.operand)

		case choose(%i[symbol string splat])
		in :symbol then Refract::AssocNode.new(key: Refract::SymbolNode.new(unescaped: "k", quoted: nil), value:)
		in :string then Refract::AssocNode.new(key: Refract::StringNode.new(unescaped: "k"), value:)
		in :splat then Refract::AssocSplatNode.new(value:)
		end
	end

	private def pattern(position)
		case choose(position.assignable.empty? ? %i[integer constant] : %i[integer constant local])
		in :integer then Refract::IntegerNode.new(value: 1)
		in :constant then Refract::ConstantReadNode.new(name: :Integer)
		in :local then target(position)
		end
	end

	private def target(position)
		if position.assignable.empty?
			Refract::InstanceVariableTargetNode.new(name: choose(INSTANCE_VARIABLES))
		else
			Refract::LocalVariableTargetNode.new(name: choose(position.assignable))
		end
	end

	private def arguments(values)
		Refract::ArgumentsNode.new(arguments: values) if values.any?
	end

	private def send_call(receiver, name, arguments: nil, block: nil, safe_navigation: false, variable_call: false, attribute_write: false)
		Refract::CallNode.new(receiver:, name:, arguments:, block:, safe_navigation:, variable_call:, attribute_write:)
	end

	# A modifier needs a body and can't have an else.
	private def inline?(body, alternative)
		!!body && !alternative && boolean
	end

	private def optional
		yield if boolean
	end

	private def several(range)
		Array.new(between(range)) { @choices.span { yield } }
	end

	private def between(range)
		range.begin + @choices.choose(range.end - range.begin)
	end

	private def choose(options)
		options[@choices.choose(options.size - 1)]
	end

	private def boolean
		@choices.choose(1) == 1
	end
end
