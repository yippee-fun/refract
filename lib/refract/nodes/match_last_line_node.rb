# frozen_string_literal: true

module Refract
	class MatchLastLineNode < Node
		def initialize(prism_node: nil, unescaped:, ignore_case:, multi_line:, extended:, once:)
			@prism_node = prism_node => Prism::Node | nil
			@unescaped = unescaped
			@ignore_case = ignore_case
			@multi_line = multi_line
			@extended = extended
			@once = once
			freeze
		end

		attr_accessor :unescaped, :ignore_case, :multi_line, :extended, :once
	end
end
