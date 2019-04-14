# frozen_string_literal: true

require 'mongo'

module CodePraise
  module Database
    class ProjectFolderContributionsOdm
      CLIENT = Mongo::Client.new(CodePraise::Api.config.MONGODB_URL)
      COLLECTION = CLIENT['project_folder_contributions']

      attr_reader :document, :project,  :folder, :commits

      def initialize(document)
        @document = document
        @project = document['project']
        @folder = document['folder']
        @commits = document['commits']
      end

      def update(document)
        COLLECTION.update_one(@document, '$set': document)
        @document.merge!(document)
      end

      def save
        @save ||= COLLECTION.insert_one(@document)
        @save.count == 1
      end

      def delete
        COLLECTION.delete_one(@document)
      end

      def self.find(document)
        return nil if COLLECTION.find(document).first.nil?

        COLLECTION.find(document).map do |doc|
          new(doc)
        end
      end
    end
  end
end
