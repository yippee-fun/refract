# frozen_string_literal: true

module Refract
	class AliasMethodNode < Node
		def initialize(new_name:, old_name:)
			@new_name = new_name => SymbolNode
			@old_name = old_name => SymbolNode
		end

		attr_reader :new_name
		attr_reader :old_name
	end
end
