# frozen_string_literal: true

require_relative "semantic_tree"

# Round trips every Ruby file in the standard library and the latest version
# of each installed gem, and groups the failures by node type.
module Corpus
	extend self

	Failure = Data.define(:kind, :type, :detail, :path) do
		def key = "#{kind} #{type}"
	end

	def files
		stdlib = Dir[File.join(RbConfig::CONFIG["rubylibdir"], "**", "*.rb")]

		gems = Dir[File.join(Gem.dir, "gems", "*")]
			.group_by { |dir| File.basename(dir).sub(/-[^-]+\z/, "") }
			.map { |_, dirs| dirs.max_by { |dir| Gem::Version.new(File.basename(dir)[/[^-]+\z/][/\A[\d.]+/] || "0") } }
			.flat_map { |dir| Dir[File.join(dir, "**", "*.rb")] }

		(stdlib + gems).sort
	end

	def check(path)
		source = File.binread(path)
		original = Prism.parse(source)
		return unless original.errors.empty?

		source = source.force_encoding(original.value.slice.encoding)
		result = SemanticTree.round_trip(source)

		if result.errors.any?
			type = smallest_failing_statement(original.value)&.type || :program_node
			Failure.new(kind: :syntax, type:, detail: result.errors.first.message, path:)
		elsif (mismatch = result.mismatch)
			Failure.new(kind: :mismatch, type: mismatch.type, detail: mismatch.path.join(" > "), path:)
		end
	rescue => error
		type = error.backtrace_locations&.find { |it| it.path.end_with?("formatter.rb", "converter.rb") }&.label
		Failure.new(kind: :error, type: "#{error.class} #{type}", detail: error.message.lines.first&.strip, path:)
	end

	def report(failures)
		failures.group_by(&:key).sort_by { |_, group| -group.length }.map do |key, group|
			examples = group.first(3).map { |it| "    #{it.path}\n      #{it.detail}" }
			"#{key} (#{group.length})\n#{examples.join("\n")}"
		end.join("\n")
	end

	private def smallest_failing_statement(node)
		statements = []
		queue = [node]
		while (current = queue.shift)
			statements.concat(current.body) if Prism::StatementsNode === current
			queue.concat(current.compact_child_nodes)
		end

		statements.reverse.find do |statement|
			Prism.parse(Refract::Formatter.new.format_node(Refract::Converter.new.visit(statement)).source).errors.any?
		rescue
			false
		end
	end
end
