# frozen_string_literal: true

module RuboCop
	module Cop
		module Refract
			class OrderedVisitMethods < Base
				extend AutoCorrector

				MSG = "Visit blocks should be sorted alphabetically by node type. Expected `visit %<expected>s` but found `visit %<actual>s`."

				def on_class(node)
					visit_blocks = find_visit_blocks(node)
					return if visit_blocks.size < 2

					check_ordering(visit_blocks)
				end

				private def find_visit_blocks(class_node)
					visit_blocks = []

					class_node.each_descendant(:block) do |block_node|
						send_node = block_node.send_node
						next unless visit_method_call?(send_node)

						visit_blocks << {
							node: block_node,
							node_type: extract_node_type(send_node),
							line: block_node.loc.line,
						}
					end

					visit_blocks
				end

				private def visit_method_call?(node)
					return false unless node.send_type?
					node.method_name == :visit &&
						node.arguments.size == 1 &&
						node.first_argument.const_type?
				end

				private def extract_node_type(node)
					node.first_argument.const_name
				end

				private def check_ordering(visit_blocks)
					sorted_blocks = visit_blocks.sort_by { |b| b[:node_type] }

					visit_blocks.each_with_index do |block, index|
						next if block[:node_type] == sorted_blocks[index][:node_type]

						expected_type = sorted_blocks[index][:node_type]
						actual_type = block[:node_type]

						add_offense(
							block[:node].send_node.first_argument,
							message: format(MSG, expected: expected_type, actual: actual_type),
						) do |corrector|
							autocorrect(corrector, visit_blocks, sorted_blocks)
						end

						# Only report the first out-of-order block to avoid confusion
						break
					end
				end

				private def autocorrect(corrector, original_blocks, sorted_blocks)
					# Create a mapping of node types to their block sources
					block_sources = {}
					original_blocks.each do |block|
						block_sources[block[:node_type]] = extract_block_source(block[:node])
					end

					# Replace each block with its sorted version
					original_blocks.each_with_index do |original_block, index|
						sorted_type = sorted_blocks[index][:node_type]
						corrector.replace(
							original_block[:node].source_range,
							block_sources[sorted_type],
						)
					end
				end

				private def extract_block_source(block_node)
					# Get the source including proper indentation
					source = block_node.source

					# Check if there's a blank line after this block
					if has_blank_line_after?(block_node)
						source += "\n"
					end

					source
				end

				private def has_blank_line_after?(node)
					last_line = node.loc.end.line
					next_line = last_line + 1

					return false if next_line >= processed_source.lines.size

					processed_source.lines[next_line].blank?
				end
			end
		end
	end
end
