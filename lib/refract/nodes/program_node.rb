# frozen_string_literal: true

module Refract
	class ProgramNode < Node
		def initialize(statements:)
			@statements = statements
		end

		attr_reader :statements
	end
end
