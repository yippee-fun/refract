# frozen_string_literal: true

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

		def type
			self.class.type
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

		def update(**props)
			props.each do |k, v|
				public_send("#{k}=", v)
			end
		end
	end
end
