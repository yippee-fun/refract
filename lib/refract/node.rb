# frozen_string_literal: true

module Refract
	class Node
		def self.snake_case_name
			demodularized_name = name.split("::").last
			demodularized_name.gsub(/(?<=[A-Z])(?=[A-Z][a-z])|(?<=[a-z\d])(?=[A-Z])/, "_").downcase
		end

		def self.inherited(node)
			node.class_eval <<~RUBY, __FILE__, __LINE__ + 1
				# frozen_string_literal: true

				def accept(visitor)
					visitor.visit_#{node.snake_case_name}(self)
				end
			RUBY
		end
	end
end
