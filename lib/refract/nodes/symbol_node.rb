# frozen_string_literal: true

module Refract
	class SymbolNode < Node
		def initialize(prism_node: nil, unescaped:)
			@prism_node = prism_node => Prism::Node | nil
			@unescaped = unescaped
			freeze
		end

		attr_accessor :unescaped
	end
end
