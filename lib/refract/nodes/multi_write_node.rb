# frozen_string_literal: true

module Refract
	class MultiWriteNode < Node
		def initialize(prism_node: nil, lefts:, rest:, rights:, value:)
			@prism_node = prism_node => Prism::Node | nil
			@lefts = lefts
			@rest = rest
			@rights = rights
			@value = value
			freeze
		end

		attr_accessor :lefts, :rest, :rights, :value
	end
end
