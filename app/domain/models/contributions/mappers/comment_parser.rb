# frozen_string_literal: true

module CodePraise
  module Mapper
    module CommentParser
      MULTILINE = 2
      COMMENT = '#'

      def self.parse(line_entities)
        comments = []
        comment_lines = []
        line_entities.each do |line_entity|
          if comment?(line_entity)
            comment_lines.push(line_entity)
          elsif comment_lines.length.positive?
            comments.push(lines: comment_lines)
            comment_lines = []
          end
        end
        comments
      end

      def self.comment?(line_entity)
        line_entity.code.strip[0] == COMMENT
      end
    end
  end
end
