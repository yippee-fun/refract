# frozen_string_literal: true

module Refract
	class SymbolNode < Node
		def initialize(unescaped:)
			@unescaped = unescaped => String
		end

		attr_reader :unescaped
	end
end
