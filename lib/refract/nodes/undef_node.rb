# frozen_string_literal: true

module Refract
	class UndefNode < Node
		def initialize(names:)
			@names = names
		end

		attr_accessor :names
	end
end
