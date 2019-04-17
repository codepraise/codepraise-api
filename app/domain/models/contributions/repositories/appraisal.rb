# frozen_string_literal: true

require 'base64'

module CodePraise
  module Repository
    class Appraisal
      def self.find(project_owner, project_name)
        key = document_key(project_owner+project_name)
        db_record = Database::AppraisalOdm
          .find("#{key}": { '$exists': 1 })&.first

        return nil if db_record.nil?

        build_entity(db_record, key)
      end

      def self.create(project_contributions)
        project_owner = project_contributions['project']['owner']['username']
        project_name = project_contributions['project']['name']
        key = document_key(project_owner+project_name)
        db_record = Database::AppraisalOdm
          .create("#{key}": project_contributions)
        build_entity(db_record, key)
      end

      private

      def self.build_entity(db_record, key)
        Entity::Appraisal.new(
          id: db_record.id,
          key: key,
          document: db_record.document
        )
      end

      def self.document_key(project_info)
        Base64.urlsafe_encode64(Digest::SHA256.digest(project_info))
      end

      private_class_method :document_key, :build_entity
    end
  end
end
