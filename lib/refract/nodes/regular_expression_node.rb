# frozen_string_literal: true

module Refract
	class RegularExpressionNode < Node
		def initialize(unescaped:, ignore_case:, multi_line:, extended:, once:)
			@unescaped = unescaped
			@ignore_case = ignore_case
			@multi_line = multi_line
			@extended = extended
			@once = once
		end

		attr_accessor :unescaped, :ignore_case, :multi_line, :extended, :once
	end
end
