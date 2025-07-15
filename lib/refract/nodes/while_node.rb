# frozen_string_literal: true

module Refract
	class WhileNode < Node
		def initialize(predicate:, statements:)
			@predicate = predicate
			@statements = statements
		end

		attr_accessor :predicate, :statements
	end
end
