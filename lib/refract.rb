# frozen_string_literal: true

require "prism"
require "zeitwerk"

module Refract
	Loader = Zeitwerk::Loader.for_gem.tap do |loader|
		loader.ignore("#{__dir__}/rubocop")
		loader.collapse("#{__dir__}/refract/nodes")
		loader.setup
	end

	class Node
		def self.type
			@type ||= begin
				raise ArgumentError, "Anonymous node classes have no type. Assign #{self} to a constant before using it." unless name

				name.split("::").last.gsub(/(?<=[A-Z])(?=[A-Z][a-z])|(?<=[a-z\d])(?=[A-Z])/, "_").downcase.freeze
			end
		end

		def self.visit_method
			@visit_method ||= :"visit_#{type}"
		end

		def self.attributes
			@attributes ||= instance_method(:initialize).parameters.filter_map do |parameter|
				case parameter
				in [:key | :keyreq, :prism_node] then nil
				in [:key | :keyreq, name] then name
				end
			end.freeze
		end

		def self.inherited(node_class)
			super

			if node_class.name
				node_class.class_eval("def accept(visitor) = visitor.#{node_class.visit_method}(self)", __FILE__, __LINE__)
			else
				node_class.define_method(:accept, Node.instance_method(:accept))
			end
		end

		def self.method_added(method_name)
			super
			return unless :initialize == method_name

			@attributes = nil
			class_eval(<<~RUBY, __FILE__, __LINE__ + 1)
				# frozen_string_literal: true

				def copy(#{attributes.map { |name| "#{name}: @#{name}" }.join(', ')})
					self.class.new(prism_node: @prism_node, #{attributes.map { |name| "#{name}:" }.join(', ')})
				end

				def freeze
					#{attributes.map { |name| "@#{name}.freeze if Array === @#{name} || Hash === @#{name} || String === @#{name}" }.join("\n")}
					super
				end
			RUBY
		end

		attr_reader :prism_node

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
			visitor.__send__(self.class.visit_method, self)
		end

		def start_line
			@prism_node&.location&.start_line
		end
	end

	extend self

	def format_node(node)
		Formatter.new.format_node(node).source
	end
end
