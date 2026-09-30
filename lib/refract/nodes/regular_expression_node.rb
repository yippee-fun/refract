# frozen_string_literal: true

module Refract
	class RegularExpressionNode < Node
		def initialize(prism_node: nil, unescaped:, ignore_case:, multi_line:, extended:, once:, encoding: nil)
			@prism_node = prism_node => Prism::Node | nil
			@unescaped = unescaped
			@ignore_case = ignore_case
			@multi_line = multi_line
			@extended = extended
			@once = once
			@encoding = encoding => :ascii_8bit | :euc_jp | :windows_31j | :utf_8 | nil
			freeze
		end

		attr_accessor :unescaped, :ignore_case, :multi_line, :extended, :once, :encoding
	end
end
