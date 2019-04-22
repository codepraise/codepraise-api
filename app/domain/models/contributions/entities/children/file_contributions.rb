# frozen_string_literal: true

module CodePraise
  module Entity
    # Entity for file contributions
    class FileContributions
      include Mixins::ContributionsCalculator

      DOT = '\.'
      LINE_END = '$'
      WANTED_EXTENSION = %w[rb js css html slim md].join('|')
      EXTENSION_REGEX = /#{DOT}#{WANTED_EXTENSION}#{LINE_END}/.freeze

      attr_reader :file_path, :lines, :complexity, :idiomaticity, :methods, :comments, :test_cases, :commits_count

      def initialize(file_path:, lines:, complexity:, idiomaticity:, methods:, comments:, test_cases:, commits_count:)
        @file_path = Value::FilePath.new(file_path)
        @lines = lines
        @complexity = complexity
        @idiomaticity = idiomaticity
        @methods = methods
        @comments = comments
        @test_cases = test_cases
        @commits_count = commits_count
      end

      def total_line_credits
        line_credit_share.total_credits
      end

      def total_comments
        comments.each_with_object(Hash.new(0)) do |comment, hash|
          hash[comment.type] += 1
        end
      end

      def total_methods
        methods&.length
      end

      def has_documentation
        @comments.select(&:is_documentation).length.positive?
      end

      def ownership_level
        max_percentage = line_credit_share.share_percentage.values.max
        case max_percentage
        when 25..40
          'A'
        when 40..60
          'B'
        else
          'C'
        end
      end

      def line_credit_share
        return Value::CreditShare.new if not_wanted

        @line_credit_share ||= lines
          .each_with_object(Value::CreditShare.new) do |line, credit|
            credit.add_credit(line)
          end
      end

      def contributors
        line_credit_share.contributors
      end

      private

      def not_wanted
        !wanted
      end

      def wanted
        file_path.filename.match(EXTENSION_REGEX)
      end
    end
  end
end
