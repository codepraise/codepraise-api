# frozen_string_literal: true

module CodePraise
  module Mapper
    # Transform Flog raw data into Complexity Entity
    class Complexity
      def initialize(contributions, methods_contributions)
        @contributions = contributions
        @methods_contributions = methods_contributions
      end

      def build_entity
        return nil unless methods

        Entity::Complexity.new(
          average: average(methods),
          methods_complexity: methods
        )
      end

      private

      def methods
        none_complexity.nil? ? methods_complexity : methods_complexity + [none_complexity]
      end

      def average(methods)
        methods.map(&:complexity).reduce(&:+) / methods.length
      end

      def methods_complexity
        return nil unless @methods_contributions
          @methods_contributions.map do |method_contributions|
            ruby_code = method_contributions.lines.map(&:code).join("\n")
            complexity = abc_metric(ruby_code)
            CodePraise::Entity::MethodComplexity.new(
              complexity: complexity.average,
              contributors: method_contributions.line_credits,
              name: method_contributions.name
            )
          end
      end

      def none_complexity
        return nil

        none = @contributions - @methods_contributions.map(&:lines).flatten
        code = none.map(&:code).join("\n")
        complexity = abc_metric(code)
        if complexity.average.positive?
          CodePraise::Entity::MethodComplexity.new(
            complexity: complexity.average,
            contributors: none_contributors(none),
            name: 'none'
          )
        end
      end

      def none_contributors(none)
        none.each_with_object(Hash.new(0)) do |line, hash|
          hash[line.contributor.username] += 1
        end
      end

      def abc_metric(code)
        flog_reporter = CodePraise::Complexity::FlogReporter

        flog_reporter.flog_code(code) if code
      end
    end
  end
end
