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
        CommentParser.parse(@line_entities)
      end

      def documentation?(comment_entiies)
        return false if top_level_entity.nil?

        top_level_entity.number == comment_entiies.map(&:number).max + 1
      end

      def top_level_entity
        @top_level_entity ||= @line_entities.select do |line_entity|
          line_entity.code.include?('class') ||
            line_entity.code.include?('module')
        end.last
      end
    end
  end
end
