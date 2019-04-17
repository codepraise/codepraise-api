# frozen_string_literal: true

module CodePraise
  module Entity
    class Appraisal
      def initialize(id:, key:, document:)
        @id = id
        @key = key
        @document = document
      end

      def content(folder)
        result = @document[@key]
        result['folder'] = folder_content(folder, result['folder'])
        result
      end

      private

      def folder_content(folder, content)
        folders = folder.split('/')
        folders.each do |folder_name|
          content = content['subfolders'].select do |folder_hash|
            folder_hash['path'].split('/').last == folder_name
          end.first
        end
        content
      end
    end
  end
end
