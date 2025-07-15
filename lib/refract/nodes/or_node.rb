# frozen_string_literal: true

module Refract
	class OrNode < Node
		def initialize(left:, operator:, right:)
			@left = left
			@operator = operator
			@right = right
		end

		attr_accessor :left, :operator, :right
	end
end
