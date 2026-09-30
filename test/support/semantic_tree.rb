# frozen_string_literal: true

# Reduces a Prism tree to the parts that affect what the code does, so a
# Converter→Formatter round trip can be compared with the original. Locations
# are dropped, along with flags and node shapes that only record how the
# source was written (integer bases, heredocs vs quoted strings, adjacent
# literal concatenation, implicit vs explicit `begin` in bodies).
module SemanticTree
	extend self

	Mismatch = Data.define(:type, :path, :original, :regenerated)
	RoundTrip = Data.define(:source, :errors, :mismatch)

	IGNORED_FLAGS = %i[
		binary? decimal? octal? hexadecimal?
		forced_utf8_encoding? forced_binary_encoding? forced_us_ascii_encoding?
	].freeze

	BODY_OWNERS = [
		Prism::DefNode,
		Prism::BlockNode,
		Prism::LambdaNode,
		Prism::ClassNode,
		Prism::ModuleNode,
		Prism::SingletonClassNode,
	].freeze

	INTERPOLATED = [
		Prism::InterpolatedStringNode,
		Prism::InterpolatedSymbolNode,
		Prism::InterpolatedXStringNode,
		Prism::InterpolatedRegularExpressionNode,
		Prism::InterpolatedMatchLastLineNode,
	].freeze

	REGEXPS = [
		Prism::RegularExpressionNode,
		Prism::MatchLastLineNode,
		Prism::InterpolatedRegularExpressionNode,
		Prism::InterpolatedMatchLastLineNode,
	].freeze

	def round_trip(source)
		original = Prism.parse(source)
		output = Refract::Formatter.new.format_node(Refract::Converter.new.visit(original.value)).source
		regenerated = Prism.parse(output)

		RoundTrip.new(
			source: output,
			errors: regenerated.errors,
			mismatch: (compare(of(original.value), of(regenerated.value)) if regenerated.errors.empty?),
		)
	end

	def of(node)
		case node
		when nil
			nil
		when Prism::SourceLineNode
			[:integer_node, [[:value, node.location.start_line]]]
		when Prism::InterpolatedStringNode
			parts = parts(node)
			case parts
			in [] | [[:string, *]]
				[:string_node, [[:flags, flags(node)], [:unescaped, parts.dig(0, 1) || ["".b, Encoding::UTF_8]]]]
			else
				[:interpolated_string_node, [[:flags, flags(node)], [:parts, parts]]]
			end
		when *INTERPOLATED
			[node.type, fields(node).map { |name, value| [name, (name == :parts) ? parts(node) : value] }]
		when *BODY_OWNERS
			[node.type, fields(node).map { |name, value| [name, (name == :body) ? body(node.body) : value] }]
		else
			[node.type, fields(node)]
		end
	end

	def compare(original, regenerated, path = [])
		return if original == regenerated

		case [original, regenerated]
		in [[Symbol => type, Array => a], [^type, Array => b]] if a.length == b.length
			a.zip(b) do |(name, x), (_, y)|
				next if x == y

				if node?(x) && node?(y)
					return compare(x, y, [*path, type])
				elsif Array === x && Array === y && x.length == y.length && x.any? { |it| node?(it) }
					x.zip(y) { |xi, yi| return compare(xi, yi, [*path, type]) unless xi == yi }
				end

				return Mismatch.new(type:, path: [*path, type], original: x, regenerated: y)
			end
		else
			type = node?(original) ? original[0] : path.last
			Mismatch.new(type:, path:, original:, regenerated:)
		end
	end

	private def fields(node)
		Prism::Reflection.fields_for(node.class).filter_map do |field|
			case field
			when Prism::Reflection::LocationField, Prism::Reflection::OptionalLocationField
				nil
			when Prism::Reflection::FlagsField
				[:flags, flags(node)]
			when Prism::Reflection::NodeListField
				[field.name, node.public_send(field.name).map { |child| of(child) }]
			when Prism::Reflection::NodeField, Prism::Reflection::OptionalNodeField
				[field.name, of(node.public_send(field.name))]
			when Prism::Reflection::StringField
				[field.name, string(node, node.public_send(field.name))]
			else
				[field.name, node.public_send(field.name)]
			end
		end
	end

	private def flags(node)
		field = Prism::Reflection.fields_for(node.class).find { |it| Prism::Reflection::FlagsField === it }
		return [] unless field

		(field.flags - IGNORED_FLAGS).select { |flag| node.public_send(flag) }
	end

	private def string(node, value)
		value = normalize_regexp(value) if REGEXPS.any? { |it| it === node }

		encoding = if node.respond_to?(:forced_utf8_encoding?) && node.forced_utf8_encoding?
			Encoding::UTF_8
		elsif node.respond_to?(:forced_binary_encoding?) && node.forced_binary_encoding?
			Encoding::BINARY
		else
			value.encoding
		end

		[value.b, encoding]
	end

	# `\/` and `/` are the same regexp, but only one can appear inside `/.../`.
	private def normalize_regexp(value)
		value.b.gsub(%r{\\.}mn) { |escape| (escape == "\\/") ? "/" : escape }
	end

	private def parts(node)
		flatten(node.parts).each_with_object([]) do |part, parts|
			case part
			when Prism::StringNode
				bytes, encoding = string(node, part.unescaped)
				next if bytes.empty?

				if parts.last in [:string, [previous, _]]
					parts[-1] = [:string, [previous + bytes, encoding]]
				else
					parts << [:string, [bytes, encoding]]
				end
			else
				parts << of(part)
			end
		end
	end

	private def flatten(parts)
		parts.flat_map { |part| (Prism::InterpolatedStringNode === part) ? flatten(part.parts) : part }
	end

	private def body(node)
		if Prism::StatementsNode === node && node.body in [Prism::BeginNode => begin_node]
			of(begin_node)
		else
			of(node)
		end
	end

	private def node?(value)
		Array === value && Symbol === value[0] && value[0].end_with?("_node")
	end
end
