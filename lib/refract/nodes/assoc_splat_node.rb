# frozen_string_literal: true

module Refract
	class AssocSplatNode < Node
		def initialize(prism_node: nil, value:)
			@prism_node = prism_node => Prism::Node | nil
			@value = value
			freeze
		end

		attr_accessor :value
	end
end
