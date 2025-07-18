# frozen_string_literal: true

module Refract
	class RescueNode < Node
		def initialize(prism_node: nil, exceptions:, reference:, statements:, subsequent:)
			@prism_node = prism_node => Prism::Node | nil
			@exceptions = exceptions
			@reference = reference
			@statements = statements
			@subsequent = subsequent
			freeze
		end

		attr_accessor :exceptions, :reference, :statements, :subsequent
	end
end
