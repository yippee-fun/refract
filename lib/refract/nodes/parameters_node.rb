# frozen_string_literal: true

module Refract
	class ParametersNode < Node
		def initialize(requireds:, optionals:, rest:, posts:, keywords:, keyword_rest:, block:)
			@requireds = requireds
			@optionals = optionals
			@rest = rest
			@posts = posts
			@keywords = keywords
			@keyword_rest = keyword_rest
			@block = block
		end

		attr_accessor :requireds, :optionals, :rest, :posts, :keywords, :keyword_rest, :block
	end
end
