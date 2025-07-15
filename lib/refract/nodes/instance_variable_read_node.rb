# frozen_string_literal: true

module Refract
	class InstanceVariableReadNode < Node
		def initialize(name:)
			@name = name
		end

		attr_accessor :name
	end
end
