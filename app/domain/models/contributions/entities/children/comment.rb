# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module CodePraise
  module Entity
    class Comment < Dry::Struct
      MULTILINE = 2
      include Dry::Types.module

      attribute :lines, Strict::Array.of(Entity::LineContribution)
      attribute :is_documentation, Strict::Bool

      def type
        if lines.size >= MULTILINE
          'mulit-line'
        else
          'single-line'
        end
      end

      def contributors
        lines.each_with_object({}) do |line, hash|
          hash[email_id(line.contributor.email)] ||= 0
          hash[email_id(line.contributor.email)] += 1
        end
      end

      private

      def email_id(email)
        email.split('@').first
      end
    end
  end
end
