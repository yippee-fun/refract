# frozen_string_literal: true

module Refract
	class RescueNode < Node
		def initialize(exceptions:, reference:, statements:, subsequent:)
			@exceptions = exceptions
			@reference = reference
			@statements = statements
			@subsequent = subsequent
		end

		attr_accessor :exceptions, :reference, :statements, :subsequent
	end
end
