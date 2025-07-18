# frozen_string_literal: true

module Refract
	class ForNode < Node
		def initialize(prism_node: nil, index:, collection:, statements:)
			@prism_node = prism_node => Prism::Node | nil
			@index = index
			@collection = collection
			@statements = statements
			freeze
		end

		attr_accessor :index, :collection, :statements
	end
end
