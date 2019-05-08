# frozen_string_literal: true

require 'date'

module CodePraise
  module SimpleCov
    # Report the test coverage by a file
    class TestCoverage
      COVERAGE_PATH = '/coverage/.resultset.json'

      def initialize(repo_path)
        path = repo_path + COVERAGE_PATH
        @coverage_hash = File.exist?(path) ? JSON.parse(File.read(path)) : nil
      end

      def coverage_report(file_path)
        return nil unless @coverage_hash

        {
          coverage: test_coverage(file_path),
          time: time
        }
      end

      def coverage_hash
        return nil unless @coverage_hash

        @coverage_hash['RSpec']['coverage']
      end

      private

      def time
        @time ||= Time.strptime(timestamp, '%s')
      end

      def timestamp
        @coverage_hash['RSpec']['timestamp'].to_s
      end

      def project_path
        @project_path ||= longest_repeating_substring(coverage_hash.keys)
      end

      def test_array(file_path)
        path = project_path + file_path
        coverage_hash[path]
      end

      def test_coverage(file_path)
        calculate_test_coverage(test_array(file_path))
      end

      def longest_repeating_substring(string_array)
        result = ''
        char_len = string_array[0].length
        char_len.times do |index|
          char_array = string_array.map { |string| string[index] }
          char_set = Set.new(char_array)
          result += char_set.first if char_set.length == 1
          break if char_set.length > 1
        end
        result
      end

      def calculate_test_coverage(coverage_array)
        return 0 if coverage_array.nil? || coverage_array.empty?

        total_lines = coverage_array.reject(&:nil?)

        return 0 if total_lines.empty?

        cover_lines = total_lines.reject(&:zero?)
        cover_lines.length.to_f / total_lines.length
      end
    end
  end
end
