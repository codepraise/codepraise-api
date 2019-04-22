# frozen_string_literal: true

require_relative 'test_case_parser'

module CodePraise
  module Mapper
    class TestCases
      def initialize(line_entities)
        @line_entities = line_entities
      end

      def build_entities
        test_cases.map do |test_case|
          Entity::TestCase.new(
            message: test_case[:message]
          )
        end
      end

      private

      def test_cases
        TestCaseParser.parse(@line_entities.map(&:code).join("\n"))
      end
    end
  end
end
