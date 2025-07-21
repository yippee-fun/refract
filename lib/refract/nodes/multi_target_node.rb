# frozen_string_literal: true

module Refract
	class MultiTargetNode < Node
		def initialize(prism_node: nil, lefts:, rest:, rights:)
			@prism_node = prism_node => Prism::Node | nil
			@lefts = lefts
			@rest = rest
			@rights = rights
			freeze
		end

		attr_accessor :lefts, :rest, :rights
	end
end
