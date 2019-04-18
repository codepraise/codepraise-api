# frozen_string_literal: true

require_relative 'comment_parser'

module CodePraise
  module Mapper
    # Transform Flog raw data into Complexity Entity
    class Comments
      def initialize(line_entities, file_path)
        @line_entities = line_entities
        @file_path  = file_path
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

      def file_name
        extname = File.extname(@file_path)
        @file_path.split('/').last.gsub(extname, '')
      end

      def comments
        CommentParser.parse(@line_entities)
      end

      def documentation?(comment_entiies)
        top_level_entity.number == comment_entiies.map(&:number).max + 1
      end

      def top_level_entity
        @line_entities.select do |line_entity|
          line_entity.code.include?(file_name.classify)
        end.first
      end
    end
  end
end
