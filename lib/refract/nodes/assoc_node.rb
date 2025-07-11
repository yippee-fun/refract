# frozen_string_literal: true

module Refract
	class AssocNode < Node
		def initialize(key:, value:)
			@key = key => Node
			@value = value => Node
		end

		attr_reader :key
		attr_reader :value
	end
end
