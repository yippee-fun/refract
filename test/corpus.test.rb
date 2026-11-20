# frozen_string_literal: true

class CorpusTest < Quickdraw::Test
	# Slow: round trips every Ruby file in the standard library and installed
	# gems, in batches of files from one package. Run with
	# `CORPUS=1 bundle exec qd test/corpus.test.rb`. Set CORPUS to a path
	# fragment (e.g. `CORPUS=rubygems`) to only check matching files.
	if ENV["CORPUS"]
		require_relative "support/corpus"

		filter = ENV["CORPUS"] unless ENV["CORPUS"] == "1"

		Corpus.groups(filter).each do |name, files|
			test name do
				failures = files.filter_map { |path| Corpus.check(path) }

				assert(failures.empty?) do
					"#{failures.length} of #{files.length} files changed meaning:\n#{Corpus.report(failures)}"
				end
			end
		end
	end
end
