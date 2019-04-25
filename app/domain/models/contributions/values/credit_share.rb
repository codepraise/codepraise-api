# frozen_string_literal: true

module CodePraise
  module Value
    # Value of credits shared by contributors for file, files, or folder
    class CreditShare
      # rubocop:disable Style/RedundantSelf
      LEVEL_SCORE = {
        'A' => 10,
        'B' => 9,
        'C' => 8,
        'D' => 7,
        'E' => 6,
        'F' => 5
      }.freeze

      attr_accessor :line_credits, :quality_credits, :method_credits
      attr_reader :contributors, :collective_ownership

      def initialize
        @line_credits = Types::HashedIntegers.new
        @quality_credits = { complexity: Types::HashedIntegers.new,
                             idiomaticity: Types::HashedIntegers.new }
        @method_credits = Types::HashedIntegers.new
        @collective_ownership = Hash.new()
        @contributors = Set.new
      end

      ### following methods allow two CreditShare objects to test equality
      def sorted_credit
        @share.to_a.sort_by { |a| a[0] }
      end

      def sorted_contributors
        @contributors.to_a.sort_by(&:username)
      end

      def state
        [sorted_credit, sorted_contributors]
      end

      def ==(other)
        other.class == self.class && other.state == self.state
      end

      def line_percentage
        sum = line_credits.values.reduce(&:+)
        line_credits.keys.inject({}) do |result, key|
          if sum.zero?
            result[key] = 0
          else
            result[key] = ((line_credits[key].to_f / sum) * 100).round
          end
          result
        end
      end

      alias eql? ==

      def hash
        state.hash
      end
      #############

      def total_line_credits
        @line_credits.values.sum
      end

      def add_line_credit(line)
        @line_credits[line.contributor.username] += line.credit
        @contributors.add(line.contributor)
      end

      def add_quality_credits(complexity_level, idiomaticity_level)
        @contributors.each do |contributor|
          name = contributor.username
          @quality_credits[:complexity][name] = LEVEL_SCORE[complexity_level] *
                                                (line_percentage[name].to_f / 100)
          @quality_credits[:idiomaticity][name] = LEVEL_SCORE[idiomaticity_level] *
                                                  (line_percentage[name].to_f / 100)
        end
      end

      def add_method_credits(methods)
        methods.each do |method|
          total = method.line_credits.values.sum
          method.line_credits.each do |k, v|
            @method_credits[k] += (v.to_f / total)
          end
        end
      end

      def add_collective_ownership(ownership_score)
        ownership_score.each do |k, v|
          @collective_ownership[k] = {
            coefficient_variation: ownership_score[k],
            level: coefficient_variantion_level(ownership_score[k])
          }
        end
      end

      def coefficient_variantion_level(coefficient_variantion)
        case coefficient_variantion
        when 0..50
          'A'
        when 50..100
          'B'
        when 100..150
          'C'
        when 150..200
          'D'
        when 200..250
          'E'
        when 250..(1.0 / 0.0)
          'F'
        end
      end

      def add_credits(contributor, credits_1, credits_2)
        name = contributor.username
        @line_credits[name] += credits_1[:line_credits] +
                               credits_2[:line_credits]
        @quality_credits.keys.each do |k|
          @quality_credits[k][name] += credits_1[:quality_credits][k] +
                                       credits_2[:quality_credits][k]
        end
        @method_credits[name] += credits_1[:method_credits] +
                                 credits_2[:method_credits]
        @contributors.add(contributor)
      end

      def +(other)
        all_contributors = self.contributors + other.contributors
        all_contributors
          .each_with_object(Value::CreditShare.new) do |contributor, total|
            total.add_credits(contributor,
                              self.by_contributor(contributor),
                              other.by_contributor(contributor))
          end
      end

      def by_email(email)
        contributor = @contributors.find { |c, _| c.email == email }
        by_contributor(contributor)
      end

      def by_contributor(contributor)
        {
          line_credits: @line_credits[contributor.username],
          quality_credits: {
            complexity: @quality_credits[:complexity][contributor.username],
            idiomaticity: @quality_credits[:idiomaticity][contributor.username]
          },
          method_credits: @method_credits[contributor.username]
        }
      end
      # rubocop:enable Style/RedundantSelf
    end
  end
end
