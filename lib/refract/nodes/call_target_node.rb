# frozen_string_literal: true

module Refract
	class CallTargetNode < Node
		def initialize(prism_node: nil, receiver:, name:, safe_navigation: nil)
			@prism_node = prism_node => Prism::Node | nil
			@receiver = receiver
			@name = name
			@safe_navigation = safe_navigation
			freeze
		end

		attr_reader :receiver, :name, :safe_navigation
	end
end
