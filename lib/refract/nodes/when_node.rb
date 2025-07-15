# frozen_string_literal: true

module Refract
	class WhenNode < Node
		def initialize(conditions:, statements:)
			@conditions = conditions
			@statements = statements
		end

		attr_accessor :conditions, :statements
	end
end
