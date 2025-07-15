# frozen_string_literal: true

module Refract
	class LocalVariableOrWriteNode < Node
		def initialize(name:, value:, depth:)
			@name = name
			@value = value
			@depth = depth
		end

		attr_accessor :name, :value, :depth
	end
end
