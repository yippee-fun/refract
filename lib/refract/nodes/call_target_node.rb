# frozen_string_literal: true

module Refract
	class CallTargetNode < Node
		def initialize(receiver:, name:)
			@receiver = receiver
			@name = name
		end

		attr_accessor :receiver, :name
	end
end
