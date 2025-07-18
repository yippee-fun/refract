# frozen_string_literal: true

module Refract
	class BasicVisitor
		def initialize
			@stack = []
		end

		def self.visit(node_class, &)
			define_method("visit_#{node_class.type}", &)
		end

		def around_visit(node)
			yield(node)
		end

		def visit(node)
			return unless node

			@stack.push(node)
			around_visit(node) do |n|
				n.accept(self).tap { @stack.pop }
			end
		end

		def visit_each(nodes)
			nodes = nodes.compact

			i, len = 0, nodes.length
			if block_given?
				while i < len
					node = nodes[i]
					i += 1
					visit node
					yield unless i == len
				end
			else
				while i < len
					visit nodes[i]
					i += 1
				end
			end
		end
	end
end
