# frozen_string_literal: true

module Refract
	class AssocNode < Node
		def initialize(prism_node: nil, key:, value:)
			@prism_node = prism_node => Prism::Node | nil
			@key = key
			@value = value
			freeze
		end

		attr_accessor :key, :value
	end
end
