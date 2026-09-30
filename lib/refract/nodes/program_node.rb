# frozen_string_literal: true

module Refract
	class ProgramNode < Node
		def initialize(prism_node: nil, statements:, frozen_string_literal: nil, encoding: nil)
			@prism_node = prism_node => Prism::Node | nil
			@statements = statements
			@frozen_string_literal = frozen_string_literal => true | false | nil
			@encoding = encoding => Encoding | nil
			freeze
		end

		attr_accessor :statements, :frozen_string_literal, :encoding
	end
end
