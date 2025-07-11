# frozen_string_literal: true

module Refract
	class AndNode < Node
		def initialize(left:, operator:, right:)
			@left = left => Node
			@operator = operator => "and" | "&&"
			@right = right => Node
		end

		attr_reader :left
		attr_reader :operator
		attr_reader :right
	end
end
