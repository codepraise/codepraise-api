# frozen_string_literal: true

require_relative '../lib/measurement/complexity'
require_relative '../lib/measurement/idiomaticity'
require_relative '../lib/measurement/number_of_annotation'

module CodePraise
  module Mapper
    # Summarizes a single file's contributions by team members
    class FileContributions
      def initialize(file_report, repo_path)
        @file_report = file_report
        @repo_path = repo_path
      end

      def build_entity
        Entity::FileContributions.new(
          file_path: filename,
          lines: contributions,
          complexity: complexity,
          idiomaticity: idiomaticity,
          methods: methods,
          total_annotations: total_annotations
        )
      end

      private

      def filename
        @file_report[0]
      end

      def contributions
        summarize_line_reports(@file_report[1])
      end

      def complexity
        file_path = Value::FilePath.new(filename)
        complexity_hash = Measurement::Complexity.calculate("#{@repo_path}/#{file_path}")
        Entity::Complexity.new(
          average: complexity_hash[:average],
          methods_complexity: complexity_hash[:methods_complexity]
        )
      end

      def idiomaticity
        file_path = Value::FilePath.new(filename)
        idiomaticity_hash = Measurement::Idiomaticity.calculate("#{@repo_path}/#{file_path}")
        Entity::Idiomaticity.new(
          error_count: idiomaticity_hash[:error_count],
          error_messages: idiomaticity_hash[:error_messages]
        )
      end

      def total_annotations
        Measurement::NumberOfAnnotation.calculate(contributions.map(&:code))
      end

      def summarize_line_reports(line_reports)
        line_reports.map.with_index do |report, line_index|
          Entity::LineContribution.new(
            contributor: contributor_from(report),
            code: strip_leading_tab(report['code']),
            time: Time.at(report['author-time'].to_i),
            number: index_to_number(line_index)
          )
        end
      end

      def methods
        return [] unless ruby_file?
        MethodContributions.new(contributions).build_entity
      end

      def ruby_file?
        File.extname(@file_report[0]) == ".rb"
      end

      def contributor_from(report)
        Entity::Contributor.new(
          username: report['author'],
          email: bare_email(report['author-mail'])
        )
      end

      # remove angle brackets <..> around email addresses
      def bare_email(email)
        email[1..-2]
      end

      # remove leading tab from git blame code output
      def strip_leading_tab(code_line)
        code_line[1..-1]
      end

      # add 1 to line indexes to make them line numbers
      def index_to_number(index)
        index + 1
      end
    end
  end
end
