# frozen_string_literal: true

# What a Refract tree means, without the parts that only say how it was
# written: parentheses and bare begins, single statement wrappers, statements
# nested in statements, modifier vs block form, quoted symbols, local depths and
# Converter's locations.
module TreeShape
	extend self

	Shape = Data.define(:type, :attributes)
	Mismatch = Data.define(:path, :expected, :actual)
	RoundTrip = Data.define(:source, :errors, :mismatch)

	def round_trip(tree)
		source = Refract::Formatter.new.format_node(tree).source
		result = Prism.parse(source)
		mismatch = (difference(of(tree), of(Refract::Converter.new.visit(result.value))) if result.errors.empty?)

		RoundTrip.new(source:, errors: result.errors.map(&:message), mismatch:)
	end

	def report(tree, round_trip)
		problem = if round_trip.errors.any?
			round_trip.errors.join("\n")
		else
			"At #{round_trip.mismatch.path.join(' > ')}:\n\nExpected #{round_trip.mismatch.expected}\n\nGot #{round_trip.mismatch.actual}"
		end

		"Tree:\n\n#{render(tree)}\n\nFormatted:\n\n#{round_trip.source}\n\n#{problem}"
	end

	def of(value)
		case value
		in Refract::ParenthesesNode then of(value.body)
		in Refract::BeginNode[rescue_clause: nil, else_clause: nil, ensure_clause: nil] then of(value.statements)
		in Refract::FlipFlopNode
			Shape.new(value.type, attributes(value).merge(left: flip_flop_operand(value.left), right: flip_flop_operand(value.right)))
		in Refract::StatementsNode
			case flatten(value.body)
			in [] then nil
			in [statement] then of(statement)
			in body then Shape.new("statements_node", { body: of(body) })
			end
		in Refract::IfNode | Refract::UnlessNode
			Shape.new(value.type, attributes(value).except(:inline))
		in Refract::SymbolNode
			Shape.new(value.type, attributes(value).except(:quoted))
		in Refract::LocalVariableReadNode | Refract::LocalVariableWriteNode | Refract::LocalVariableTargetNode
			Shape.new(value.type, attributes(value).except(:depth))
		in Refract::WhileNode | Refract::UntilNode
			do_while = !!value.inline && (value.statements in Refract::StatementsNode[body: [Refract::BeginNode]])
			Shape.new(value.type, attributes(value).except(:inline).merge(do_while:))
		in Refract::Node then Shape.new(value.type, attributes(value))
		in Array then value.map { |it| of(it) }
		else value
		end
	end

	def difference(expected, actual, path = [])
		return if expected == actual

		case [expected, actual]
		in [Shape[type:, attributes: Hash => left], Shape[type: ^type, attributes: Hash => right]]
			left.each do |name, value|
				found = difference(value, right[name], [*path, "#{type}.#{name}"])
				return found if found
			end
		in [Array, Array] if expected.size == actual.size
			expected.zip(actual).each_with_index do |(left, right), index|
				found = difference(left, right, [*path, index])
				return found if found
			end
		else
			Mismatch.new(path:, expected: render(expected), actual: render(actual))
		end
	end

	def render(value)
		case value
		in Shape[type:, attributes:]
			fields = attributes.filter_map { |name, field| "#{name}: #{render(field)}" if field in true | String | Symbol | Integer | Encoding | Shape | [_, *] }
			"(#{[type.delete_suffix('_node'), *fields].join(' ')})"
		in Array then "[#{value.map { |it| render(it) }.join(', ')}]"
		in Refract::Node then render(of(value))
		else value.inspect
		end
	end

	private def attributes(node)
		node.class.attributes.to_h { |name| [name, of(node.public_send(name))] }
	end

	# An integer literal as a flip-flop's operand compares with `$.`, unless it's in parentheses.
	private def flip_flop_operand(operand)
		case operand
		in Refract::ParenthesesNode[body: Refract::StatementsNode[body: [Refract::IntegerNode => integer]]]
			Shape.new(operand.type, { body: of(integer) })
		else of(operand)
		end
	end

	private def flatten(body)
		body.flat_map do |statement|
			case statement
			in Refract::StatementsNode then flatten(statement.body)
			in Refract::ParenthesesNode[body: Refract::StatementsNode => inner] then flatten(inner.body)
			in Refract::BeginNode[statements: Refract::StatementsNode => inner, rescue_clause: nil, else_clause: nil, ensure_clause: nil] then flatten(inner.body)
			else [statement]
			end
		end
	end
end
