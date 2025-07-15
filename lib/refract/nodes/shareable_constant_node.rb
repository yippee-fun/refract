# frozen_string_literal: true

module Refract
	class ShareableConstantNode < Node
		def initialize(write:)
			@write = write
		end

		attr_accessor :write
	end
end
