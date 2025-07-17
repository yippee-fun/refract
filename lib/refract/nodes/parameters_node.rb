# frozen_string_literal: true

module Refract
	class ParametersNode < Node
		def initialize(prism_node: nil, requireds:, optionals:, rest:, posts:, keywords:, keyword_rest:, block:)
			@prism_node = prism_node => Prism::Node | nil
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
