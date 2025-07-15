# frozen_string_literal: true

module Refract
	class SymbolNode < Node
		def initialize(unescaped:)
			@unescaped = unescaped
		end

		attr_accessor :unescaped
	end
end
