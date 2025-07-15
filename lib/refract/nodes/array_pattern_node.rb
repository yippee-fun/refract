# frozen_string_literal: true

module Refract
	class ArrayPatternNode < Node
		def initialize(constant:, requireds:, rest:, posts:)
			@constant = constant
			@requireds = requireds
			@rest = rest
			@posts = posts
		end

		attr_accessor :constant, :requireds, :rest, :posts
	end
end
