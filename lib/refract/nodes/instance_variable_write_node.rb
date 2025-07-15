# frozen_string_literal: true

module Refract
	class InstanceVariableWriteNode < Node
		def initialize(name:, value:)
			@name = name
			@value = value
		end

		attr_accessor :name, :value
	end
end
