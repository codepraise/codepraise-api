# frozen_string_literal: true

require_relative '../init.rb'
require_relative 'project_clone'

module Appraisal
  class Service
    attr_reader :cache

    def initialize(project, reporter, gitrepo, request_id)
      @project = project
      @reporter = reporter
      @gitrepo = gitrepo
      @request_id = request_id
    end

    def find_or_init_cache(project_name, owner_name)
      @cache = CodePraise::Repository::Appraisal.find_or_create_by(
        project_name: project_name,
        owner_name: owner_name
      )
      @reporter.publish(CloneMonitor.progress('STARTED'), 'processing', @request_id)
      @cache
    end

    def setup_channel_id(request_id)
      data = { request_id: request_id }
      @cache = CodePraise::Repository::Appraisal
        .update(id: @cache.id, data: data)
    end

    def clone_project
      puts "clone: #{@gitrepo.id}"
      @gitrepo.clone_locally do |line|
        @reporter.publish(CloneMonitor.progress(line), 'cloning', @request_id)
      end
    end

    def appraise_project
      @reporter.publish(CloneMonitor.progress('Appraising'), 'appraising', @request_id)
      contributions = CodePraise::Mapper::Contributions.new(@gitrepo)
      folder_contributions = contributions.for_folder('')
      commit_contributions = contributions.commits
      @project_folder_contribution = CodePraise::Value::ProjectFolderContributions
        .new(@project, folder_contributions, commit_contributions)
      @reporter.publish(CloneMonitor.progress('Appraised'), 'appraised', @request_id)
      @gitrepo.delete
    end

    def store_appraisal_cache
      return false unless @project_folder_contribution

      data = { appraisal: folder_contributions_hash }
      CodePraise::Repository::Appraisal
        .update(id: @cache.id, data: data)
      each_second(15) do
        @reporter.publish(CloneMonitor.finished_percent, 'stored', @request_id)
      end
    end

    def switch_channel(channel_id)
      @reporter.publish('0', 'switch', channel_id)
    end

    private

    def folder_contributions_hash
      CodePraise::Representer::ProjectFolderContributions
        .new(@project_folder_contribution).yield_self do |representer|
          JSON.parse(representer.to_json)
        end
    end

    def each_second(seconds)
      seconds.times do
        sleep(1)
        yield if block_given?
      end
    end
  end
end
