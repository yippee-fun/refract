# frozen_string_literal: true

module Refract
	class AliasGlobalVariableNode < Node
		def initialize(new_name:, old_name:)
			@new_name = new_name => GlobalVariableReadNode
			@old_name = old_name => GlobalVariableReadNode
		end

		attr_accessor :new_name, :old_name
	end
end
