# frozen_string_literal: true

module CodePraise
  module Repository
    class ProjectFolderContributions
      def self.find_name(project_name)
        Database::ProjectFolderContributionsOdm.find({"#{project_name}": {'$exists': 1}})
      end

      def self.create(project_contributions)
        document = Database::ProjectFolderContributionsOdm.new(project_contributions)
        document.save
      end
    end
  end
end