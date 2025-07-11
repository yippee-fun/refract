# frozen_string_literal: true

module Refract
	class ArrayPatternNode < Node
		def initialize(constant:, requireds:, rest:, posts:)
			@constant = constant => ConstantReadNode | ConstantPathNode | nil
			@requireds = requireds => Array | nil
			@rest = rest => SplatNode | nil
			@posts = posts => Array | nil
		end

		attr_reader :constant
		attr_reader :requireds
		attr_reader :rest
		attr_reader :posts
	end
end
