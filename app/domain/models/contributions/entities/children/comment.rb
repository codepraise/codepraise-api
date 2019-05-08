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
          hash[line.contributor.email_id] ||= 0
          hash[line.contributor.email_id] += 1
        end
      end
    end
  end
end
