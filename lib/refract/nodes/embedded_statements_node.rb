# frozen_string_literal: true

module Refract
	class EmbeddedStatementsNode < Node
		def initialize(statements:)
			@statements = statements
		end

		attr_accessor :statements
	end
end
