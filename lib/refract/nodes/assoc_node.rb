# frozen_string_literal: true

module Refract
	class AssocNode < Node
		def initialize(key:, value:)
			@key = key
			@value = value
		end

		attr_accessor :key, :value
	end
end
