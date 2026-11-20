# frozen_string_literal: true

module RuboCop
	module Cop
		module Refract
			class OrderedVisitMethods < Base
				extend AutoCorrector

				MSG = "Visit blocks should be sorted alphabetically by node type. Expected `visit %<expected>s` but found `visit %<actual>s`."

				def_node_matcher :visited_constant, "(any_block (send nil? :visit $const) ...)"

				def on_class(node)
					return unless node.body&.begin_type?

					blocks = node.body.children.select { |child| visited_constant(child) }
					sorted = blocks.sort_by.with_index { |block, index| [node_type(block), index] }

					actual, expected = blocks.zip(sorted).find { |block, sorted_block| !block.equal?(sorted_block) }
					return unless actual

					message = format(MSG, expected: node_type(expected), actual: node_type(actual))

					add_offense(visited_constant(actual), message:) do |corrector|
						blocks.zip(sorted) { |block, sorted_block| corrector.replace(block, sorted_block.source) }
					end
				end

				private def node_type(block)
					visited_constant(block).const_name
				end
			end
		end
	end
end
