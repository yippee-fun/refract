# frozen_string_literal: true

module Refract
	class StringNode < Node
		def initialize(unescaped:)
			@unescaped = unescaped
		end

		attr_accessor :unescaped
	end
end
