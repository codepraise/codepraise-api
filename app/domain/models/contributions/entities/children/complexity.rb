# frozen_string_literal: true

module CodePraise
  module Entity
    # Complexity for file and methods of this file
    class Complexity
      attr_reader :average, :methods

      def initialize(average:, methods:)
        @average = average
        @methods = methods
      end

      def level
        case @average
        when 0..10
          'A'
        when 10..20
          'B'
        when 20..40
          'C'
        when 40..60
          'D'
        when 60..100
          'E'
        when 100..(1.0 / 0.0)
          'F'
        end
      end
    end
  end
end
