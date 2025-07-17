# frozen_string_literal: true

module Refract
	class ArrayPatternNode < Node
		def initialize(prism_node: nil, constant:, requireds:, rest:, posts:)
			@prism_node = prism_node => Prism::Node | nil
			@constant = constant
			@requireds = requireds
			@rest = rest
			@posts = posts
		end

		attr_accessor :constant, :requireds, :rest, :posts
	end
end
