# frozen_string_literal: true

# Slow: round trips every Ruby file in the standard library and installed
# gems. Run with `CORPUS=1 bundle exec qt test/corpus.test.rb`. Set CORPUS to
# a path fragment (e.g. `CORPUS=rubygems`) to only check matching files.
if ENV["CORPUS"]
	require_relative "support/corpus"

	test "round trips preserve the meaning of the corpus" do
		files = Corpus.files
		files = files.select { |path| path.include?(ENV["CORPUS"]) } unless ENV["CORPUS"] == "1"

		failures = files.filter_map { |path| Corpus.check(path) }

		assert(failures.empty?) do
			"#{failures.length} of #{files.length} files changed meaning:\n#{Corpus.report(failures)}"
		end
	end
end
