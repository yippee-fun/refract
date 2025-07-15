# frozen_string_literal: true

module Refract
	class ClassNode < Node
		def initialize(constant_path:, superclass:, body:)
			@constant_path = constant_path
			@superclass = superclass
			@body = body
		end

		attr_accessor :constant_path, :superclass, :body
	end
end
