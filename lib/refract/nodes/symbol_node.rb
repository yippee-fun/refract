# frozen_string_literal: true

module Refract
	class SymbolNode < Node
		def initialize(prism_node: nil, unescaped:, quoted:)
			@prism_node = prism_node => Prism::Node | nil
			@unescaped = unescaped
			@quoted = quoted
			freeze
		end

		attr_accessor :unescaped, :quoted
	end
end
