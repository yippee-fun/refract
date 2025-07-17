# frozen_string_literal: true

module Refract
	class InterpolatedMatchLastLineNode < Node
		def initialize(parts:, ignore_case:, multi_line:, extended:, once:)
			@parts = parts
			@ignore_case = ignore_case
			@multi_line = multi_line
			@extended = extended
			@once = once
		end

		attr_accessor :parts, :ignore_case, :multi_line, :extended, :once
	end
end
