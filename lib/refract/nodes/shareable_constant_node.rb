# frozen_string_literal: true

module Refract
	class ShareableConstantNode < Node
		def initialize(prism_node: nil, write:, value:)
			@prism_node = prism_node => Prism::Node | nil
			@write = write
			@value = value => :literal | :experimental_everything | :experimental_copy
			freeze
		end

		attr_accessor :write, :value
	end
end
