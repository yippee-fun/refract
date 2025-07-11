# frozen_string_literal: true

module Refract
	class ConstantReadNode < Node
		def initialize(name:)
			@name = name => Symbol
		end

		attr_reader :name
	end
end
