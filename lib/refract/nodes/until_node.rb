# frozen_string_literal: true

module Refract
	class UntilNode < Node
		def initialize(predicate:, statements:)
			@predicate = predicate
			@statements = statements
		end

		attr_accessor :predicate, :statements
	end
end
