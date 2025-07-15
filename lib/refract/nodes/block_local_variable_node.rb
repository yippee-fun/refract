# frozen_string_literal: true

module Refract
	class BlockLocalVariableNode < Node
		def initialize(name:)
			@name = name
		end

		attr_accessor :name
	end
end
