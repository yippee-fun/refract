# frozen_string_literal: true

module Refract
	class AliasMethodNode < Node
		def initialize(new_name:, old_name:)
			@new_name = new_name
			@old_name = old_name
		end

		attr_accessor :new_name, :old_name
	end
end
