# frozen_string_literal: true

module Refract
	class BackReferenceReadNode < Node
		def initialize(prism_node: nil, name:)
			@prism_node = prism_node => Prism::Node | nil
			@name = name
		end

		attr_accessor :name
	end
end
