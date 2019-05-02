# frozen_string_literal: true

module CodePraise
  module Mapper
    class TestCoverage
      def initialize(repo_path)
        @repo_path = repo_path
      end

      def build_entity(file_path)
        coverage_hash = test_coverage.coverage_report(file_path)
        Entity::TestCoverage.new(
          coverage: coverage_hash[:coverage],
          time: coverage_hash[:time]
        )
      end

      private

      def test_coverage
        @test_coverage ||= SimpleCov::TestCoverage.new(@repo_path)
      end
    end
  end
end
