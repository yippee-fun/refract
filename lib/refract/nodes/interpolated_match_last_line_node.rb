# frozen_string_literal: true

module Refract
	class InterpolatedMatchLastLineNode < Node
		def initialize(prism_node: nil, parts:, ignore_case:, multi_line:, extended:, once:)
			@prism_node = prism_node => Prism::Node | nil
			@parts = parts
			@ignore_case = ignore_case
			@multi_line = multi_line
			@extended = extended
			@once = once
			freeze
		end

		attr_accessor :parts, :ignore_case, :multi_line, :extended, :once
	end
end
