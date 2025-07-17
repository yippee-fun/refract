# frozen_string_literal: true

module Refract
	class ClassNode < Node
		def initialize(prism_node: nil, constant_path:, superclass:, body:)
			@prism_node = prism_node => Prism::Node | nil
			@constant_path = constant_path
			@superclass = superclass
			@body = body
		end

		attr_accessor :constant_path, :superclass, :body
	end
end
