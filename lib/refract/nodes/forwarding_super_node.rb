# frozen_string_literal: true

module Refract
	class ForwardingSuperNode < Node
		def initialize(block:)
			@block = block
		end

		attr_accessor :block
	end
end
