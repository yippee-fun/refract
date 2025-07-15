# frozen_string_literal: true

module Refract
	class ModuleNode < Node
		def initialize(constant_path:, body:)
			@constant_path = constant_path
			@body = body
		end

		attr_accessor :constant_path, :body
	end
end
