# frozen_string_literal: true

module CodePraise
  module Value
    # Value of credits shared by contributors for file, files, or folder
    class CreditShare
      # rubocop:disable Style/RedundantSelf
      attr_accessor :share
      attr_reader :contributors

      def initialize
        @share = Types::HashedIntegers.new
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

      def share_percentage
        sum = share.values.reduce(&:+)
        return nil if sum.nil? || sum == 0
        share.keys.inject({}) do |result, key|
          result[key] =  ((share[key].to_f / sum) * 100).round
          result
        end
      end

      alias eql? ==

      def hash
        state.hash
      end
      #############

      def total_credits
        @share.values.sum
      end

      def add_credit(line)
        @share[line.contributor.username] += line.credit
        @contributors.add(line.contributor)
      end

      def add_contribution(contributor, count)
        @share[contributor.username] += count
        @contributors.add(contributor)
      end

      def +(other)
        (self.contributors + other.contributors)
          .each_with_object(Value::CreditShare.new) do |contributor, total|
            total.add_contribution(contributor,
              self.by_contributor(contributor) + other.by_contributor(contributor))
          end
      end

      def by_email(email)
        contributor = @contributors.find { |c, _| c.email == email }
        by_contributor(contributor)
      end

      def by_contributor(contributor)
        @share[contributor.username]
      end
      # rubocop:enable Style/RedundantSelf
    end
  end
end
