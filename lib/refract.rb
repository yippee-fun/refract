# frozen_string_literal: true

require "prism"
require "zeitwerk"

module Refract
	Loader = Zeitwerk::Loader.for_gem.tap do |loader|
		loader.ignore("#{__dir__}/ruby_lsp")
		loader.ignore("#{__dir__}/rubocop")
		loader.collapse("#{__dir__}/refract/errors")
		loader.collapse("#{__dir__}/refract/nodes")
		loader.setup
	end

	class Node
		def self.type
			return @type if defined?(@type)
			demodularized_name = name.split("::").last
			@type = demodularized_name.gsub(/(?<=[A-Z])(?=[A-Z][a-z])|(?<=[a-z\d])(?=[A-Z])/, "_").downcase
		end

		def self.attributes
			return @attributes if defined?(@attributes)

			# CRuby lists required keywords before optional ones, TruffleRuby keeps
			# declaration order. The order reaches `inspect` and the traversal of
			# children, so it is fixed here to CRuby's: required first, each group
			# in declaration order.
			parameters = instance_method(:initialize).parameters
			parameters = parameters.each_with_index.sort_by { |(kind, _), index| [(kind == :keyreq) ? 0 : 1, index] }.map(&:first)

			@attributes = parameters.filter_map do |parameter|
				case parameter
				in [:key | :keyreq, :prism_node] then nil
				in [:key | :keyreq, name] then name
				end
			end.freeze
		end

		def type
			self.class.type
		end

		def deconstruct_keys(keys)
			attributes = self.class.attributes
			attributes &= keys if keys
			attributes.to_h { |name| [name, public_send(name)] }
		end

		def inspect
			attributes = self.class.attributes.map { |name| " #{name}: #{public_send(name).inspect}" }
			"#<#{self.class.name}#{attributes.join(',')}>"
		end

		def accept(visitor)
			self.class.class_eval(<<~RUBY, __FILE__, __LINE__ + 1)
				# frozen_string_literal: true

				def accept(visitor)
					visitor.visit_#{type}(self)
				end
			RUBY

			accept(visitor)
		end

		def start_line
			@prism_node&.location&.start_line
		end

		def copy(**props)
			duplicate = dup

			props.each do |k, v|
				duplicate.public_send("#{k}=", v)
			end

			duplicate.freeze
		end
	end

	def format_node(node)
		Formatter.new.format_node(node).source
	end
end
