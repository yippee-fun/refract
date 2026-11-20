# frozen_string_literal: true

require "rubocop"
require_relative "../lib/rubocop/cop/refract_cops"

class OrderedVisitMethodsTest < Quickdraw::Test
	test "accepts sorted blocks" do
		assert_corrects <<~RUBY, offenses: []
			class Visitor
				visit Prism::A do |node|
					a
				end

				visit Prism::B do |node|
					b
				end
			end
		RUBY
	end

	test "accepts classes with an empty or single statement body" do
		assert_corrects "class Visitor\nend\n", offenses: []
		assert_corrects "class Visitor\n\tvisit B do |node|\n\tend\nend\n", offenses: []
	end

	test "sorts blocks and keeps blank lines in place" do
		assert_corrects <<~RUBY, <<~EXPECTED, offenses: ["Expected `visit A` but found `visit B`"]
			class Visitor
				visit B do |node|
					b
				end

				visit A do |node|
					a
				end
				def x; end
			end
		RUBY
			class Visitor
				visit A do |node|
					a
				end

				visit B do |node|
					b
				end
				def x; end
			end
		EXPECTED
	end

	test "sorts by the full constant name" do
		assert_corrects <<~RUBY, <<~EXPECTED, offenses: ["Expected `visit A` but found `visit Prism::B`"]
			class Visitor
				visit Prism::B do |node|
					b
				end

				visit A do |node|
					a
				end
			end
		RUBY
			class Visitor
				visit A do |node|
					a
				end

				visit Prism::B do |node|
					b
				end
			end
		EXPECTED
	end

	test "keeps every block when a node type is visited twice" do
		assert_corrects <<~RUBY, <<~EXPECTED, offenses: ["Expected `visit A` but found `visit C`"]
			class Visitor
				visit C do |node|
					c1
				end

				visit A do |node|
					a
				end

				visit C do |node|
					c2
				end
			end
		RUBY
			class Visitor
				visit A do |node|
					a
				end

				visit C do |node|
					c1
				end

				visit C do |node|
					c2
				end
			end
		EXPECTED
	end

	test "keeps blocks for the same node type in their order" do
		visitor = -> (names) { "class Visitor\n#{names.map { |name| "\tvisit #{name[0]} do |node|\n\t\t#{name.downcase}\n\tend\n" }.join("\n")}end\n" }

		assert_corrects visitor.(%w[C1 A1 C2 A2 C3 A3 C4 A4]), visitor.(%w[A1 A2 A3 A4 C1 C2 C3 C4]), offenses: ["Expected `visit A` but found `visit C`"]
	end

	test "ignores blocks inside conditionals" do
		assert_corrects <<~RUBY, <<~EXPECTED, offenses: ["Expected `visit A` but found `visit C`"]
			class Visitor
				visit C do |node|
					c
				end

				if FEATURE
					visit B do |node|
						b
					end
				end

				visit A do |node|
					a
				end
			end
		RUBY
			class Visitor
				visit A do |node|
					a
				end

				if FEATURE
					visit B do |node|
						b
					end
				end

				visit C do |node|
					c
				end
			end
		EXPECTED
	end

	test "sorts nested classes separately" do
		assert_corrects <<~RUBY, <<~EXPECTED, offenses: ["Expected `visit A` but found `visit B`"]
			class Outer
				visit Z do |node|
					z
				end

				class Inner
					visit B do |node|
						b
					end

					visit A do |node|
						a
					end
				end
			end
		RUBY
			class Outer
				visit Z do |node|
					z
				end

				class Inner
					visit A do |node|
						a
					end

					visit B do |node|
						b
					end
				end
			end
		EXPECTED
	end

	test "ignores blocks inside other visit blocks" do
		assert_corrects <<~RUBY, <<~EXPECTED, offenses: ["Expected `visit A` but found `visit B`"]
			class Visitor
				visit B do |node|
					b
				end

				visit A do |node|
					visit Z do |n|
					end

					visit Y do |n|
					end
				end
			end
		RUBY
			class Visitor
				visit A do |node|
					visit Z do |n|
					end

					visit Y do |n|
					end
				end

				visit B do |node|
					b
				end
			end
		EXPECTED
	end

	private def assert_corrects(source, expected = source, offenses:)
		messages, corrected = investigate(source)

		assert_equal messages, offenses.map { |offense| "Refract/OrderedVisitMethods: Visit blocks should be sorted alphabetically by node type. #{offense}." }
		assert_equal corrected, expected
		assert_equal investigate(corrected), [[], corrected]
	end

	private def investigate(source)
		processed_source = RuboCop::ProcessedSource.new(source, 3.3, "visitor.rb")
		processed_source.config = RuboCop::ConfigLoader.default_configuration
		processed_source.registry = RuboCop::Cop::Registry.global

		cop = RuboCop::Cop::Refract::OrderedVisitMethods.new(RuboCop::Config.new, autocorrect: true)
		report = RuboCop::Cop::Commissioner.new([cop], [], raise_error: true).investigate(processed_source)

		corrector = RuboCop::Cop::Corrector.new(processed_source)
		report.correctors.compact.each { |cop_corrector| corrector.merge!(cop_corrector) }

		[report.offenses.map(&:message), corrector.rewrite]
	end
end
