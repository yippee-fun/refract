# frozen_string_literal: true

module Refract
	class AliasGlobalVariableNode < Node
		def initialize(prism_node: nil, new_name:, old_name:)
			@prism_node = prism_node => Prism::Node | nil
			@new_name = new_name => GlobalVariableReadNode
			@old_name = old_name => GlobalVariableReadNode
		end

		attr_accessor :new_name, :old_name
	end
end
