# frozen_string_literal: true

module Refract
	class NumberedParametersNode < Node
		def initialize(prism_node: nil)
			@prism_node = prism_node => Prism::Node | nil
		end
	end
end
