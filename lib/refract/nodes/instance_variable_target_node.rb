# frozen_string_literal: true

module Refract
	class InstanceVariableTargetNode < Node
		def initialize(name:)
			@name = name
		end

		attr_accessor :name
	end
end
