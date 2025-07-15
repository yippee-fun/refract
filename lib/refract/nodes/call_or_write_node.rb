# frozen_string_literal: true

module Refract
	class CallOrWriteNode < Node
		def initialize(receiver:, read_name:, value:)
			@receiver = receiver
			@read_name = read_name
			@value = value
		end

		attr_accessor :receiver, :read_name, :value
	end
end
