# frozen_string_literal: true

require_relative 'line_contribution'
require 'dry-types'
require 'dry-struct'

module CodePraise
  module Entity
    class TestCase < Dry::Struct
      KEY_WORD = 'Security'
      include Dry::Types.module

      attribute :message, Strict::String
      attribute :lines, Array.of(LineContribution)

      def expectation_count
        lines.select do |line|
          expectation?(line.code)
        end.count
      end

      def contributors
        lines.each_with_object({}) do |line, hash|
          hash[line.contributor.email] ||= 0
          hash[line.contributor.email] += 1 if expectation?(line.code)
        end
      end

      def is_functionality
        !(message =~ /#{KEY_WORD}/).nil?
      end

      private

      def expectation?(code)
        !(code =~ /\.must|\.wont|\.to/).nil?
      end
    end
  end
end
