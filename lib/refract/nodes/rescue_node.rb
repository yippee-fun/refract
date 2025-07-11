# frozen_string_literal: true

module Refract
	class RescueNode < Node
		def initialize(exceptions:, reference:, statements:, subsequent:)
			@exceptions = exceptions => Array
			@reference = reference => LocalVariableTargetNode | nil
			@statements = statements => StatementsNode | nil
			@subsequent = subsequent => Refract::RescueNode | nil
		end

		attr_reader :exceptions, :reference, :statements, :subsequent
	end
end
