# frozen_string_literal: true

module Refract
	class AliasMethodNode < Node
		def initialize(prism_node: nil, new_name:, old_name:)
			@prism_node = prism_node => Prism::Node | nil
			@new_name = new_name
			@old_name = old_name
			freeze
		end

		attr_accessor :new_name, :old_name
	end
end
