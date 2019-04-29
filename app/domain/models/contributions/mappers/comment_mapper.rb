# frozen_string_literal: true

require_relative 'comment_parser'

module CodePraise
  module Mapper
    # Transform Flog raw data into Complexity Entity
    class Comments
      def initialize(line_entities)
        @line_entities = line_entities
      end

      def build_entities
        comments.map do |comment|
          Entity::Comment.new(
            lines: comment[:lines],
            is_documentation: documentation?(comment[:lines])
          )
        end
      end

      private

      def comments
        @comments ||= CommentParser.parse(@line_entities)
      end

      def documentation?(comment_entiies)
        next_line = (comment_entiies.last.number + 1).yield_self do |no|
          @line_entities.select do |line_entity|
            line_entity.number == no
          end.first
        end

        method_or_class(next_line.code)
      end

      def method_or_class(code)
        !(code.strip =~ /^class|^def/).nil?
      end
    end
  end
end
