# frozen_string_literal: true

module Refract
	class NumberedReferenceReadNode < Node
		def initialize(prism_node: nil, number:)
			@prism_node = prism_node => Prism::Node | nil
			@number = number
			freeze
		end

		attr_accessor :number
	end
end
