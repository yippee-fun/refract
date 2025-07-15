# frozen_string_literal: true

module Refract
	class XStringNode < Node
		def initialize(unescaped:)
			@unescaped = unescaped
		end

		attr_accessor :unescaped
	end
end
