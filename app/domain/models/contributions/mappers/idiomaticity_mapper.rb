module CodePraise
  module Mapper
    class Idiomaticity
      def initialize(git_repo_path)
        @rubocop_reporter = Rubocop::Reporter.new(git_repo_path)
      end

      def build_entity(file_path, file_contributions)
        offenses = offenses(file_path)

        Entity::Idiomaticity.new(
          offenses: offenses,
          offense_ratio: offense_ratio(offenses, file_contributions)
        )
      end

      private

      def offenses(file_path)
        idiomaticity_result = @rubocop_reporter.report[file_path]

        return nil if idiomaticity_result.nil?

        idiomaticity_result.map do |error_hash|
          Entity::Offense.new(
            type: error_hash['cop_name'],
            message: error_hash['message'],
            location: error_hash['location'].slice('start_line', 'last_line'),
            line_count: line_count(error_hash['location'])
          )
        end
      end

      def line_count(location)
        location['last_line'] - location['start_line'] + 1
      end

      def offense_ratio(offenses, file_contributions)
        return 0.0 if offenses.nil?

        (offenses.map(&:line_count).reduce(&:+).to_f / file_contributions.size)
          .round(2)
      end
    end
  end
end
