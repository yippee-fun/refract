# frozen_string_literal: true

module Refract
	class ClassVariableOrWriteNode < Node
		def initialize(name:, value:)
			@name = name
			@value = value
		end

		attr_accessor :name, :value
	end
end
