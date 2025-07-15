# frozen_string_literal: true

module Refract
	class IfNode < Node
		def initialize(predicate:, statements:, subsequent:)
			@predicate = predicate
			@statements = statements
			@subsequent = subsequent
		end

		attr_accessor :predicate, :statements, :subsequent
	end
end
