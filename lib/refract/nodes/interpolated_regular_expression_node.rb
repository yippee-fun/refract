# frozen_string_literal: true

module Refract
	class InterpolatedRegularExpressionNode < Node
		def initialize(prism_node: nil, parts:, ignore_case:, multi_line:, extended:, once:, encoding: nil)
			@prism_node = prism_node => Prism::Node | nil
			@parts = parts
			@ignore_case = ignore_case
			@multi_line = multi_line
			@extended = extended
			@once = once
			@encoding = encoding => :ascii_8bit | :euc_jp | :windows_31j | :utf_8 | nil
			freeze
		end

		attr_accessor :parts, :ignore_case, :multi_line, :extended, :once, :encoding
	end
end
