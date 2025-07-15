# frozen_string_literal: true

module Refract
	class ForNode < Node
		def initialize(index:, collection:, statements:)
			@index = index
			@collection = collection
			@statements = statements
		end

		attr_accessor :index, :collection, :statements
	end
end
