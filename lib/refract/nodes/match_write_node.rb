# frozen_string_literal: true

module Refract
	class MatchWriteNode < Node
		def initialize(prism_node: nil, call:, targets:)
			@prism_node = prism_node => Prism::Node | nil
			@call = call
			@targets = targets
		end

		attr_accessor :call, :targets
	end
end
