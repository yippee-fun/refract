# frozen_string_literal: true

module Refract
	class ModuleNode < Node
		def initialize(prism_node: nil, constant_path:, body:)
			@prism_node = prism_node => Prism::Node | nil
			@constant_path = constant_path
			@body = body
		end

		attr_accessor :constant_path, :body
	end
end
