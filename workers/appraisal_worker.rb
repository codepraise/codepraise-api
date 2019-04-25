# frozen_string_literal: true

# require_relative '../app/infrastructure/rubocop/init.rb'
# require_relative '../app/infrastructure/database/odms/init.rb'
# require_relative '../app/infrastructure/flog/init.rb'
# require_relative '../app/domain/init.rb'
# require_relative '../app/application/values/init.rb'
# require_relative '../app/presentation/representers/init.rb'

require_relative '../init.rb'

require_relative 'progress_reporter.rb'
require_relative 'project_clone.rb'

require 'econfig'
require 'shoryuken'

module Appraisal
  # Shoryuken worker class to clone repos in parallel
  class Worker
    extend Econfig::Shortcut
    Econfig.env = ENV['RACK_ENV'] || 'development'
    Econfig.root = File.expand_path('..', File.dirname(__FILE__))

    Shoryuken.sqs_client = Aws::SQS::Client.new(
      access_key_id: config.AWS_ACCESS_KEY_ID,
      secret_access_key: config.AWS_SECRET_ACCESS_KEY,
      region: config.AWS_REGION
    )

    include Shoryuken::Worker
    Shoryuken.sqs_client_receive_message_opts = { wait_time_seconds: 20 }
    shoryuken_options queue: config.CLONE_QUEUE_URL, auto_delete: true

    def perform(_sqs_msg, request)
      project, reporter, folder_name = setup_job(request)

      reporter.publish(CloneMonitor.starting_percent)

      gitrepo = CodePraise::GitRepo.new(project, Worker.config)

      gitrepo.clone_locally do |line|
        reporter.publish CloneMonitor.progress(line)
      end

      appraise_repo(gitrepo, folder_name, project)
      reporter.publish(CloneMonitor.progress('Appraised'))
      gitrepo.delete
      # Keep sending finished status to any latecoming subscribers
      each_second(5) { reporter.publish(CloneMonitor.finished_percent) }
    rescue CodePraise::GitRepo::Errors::CannotOverwriteLocalGitRepo
      # only catch errors you absolutely expect!
      puts 'CLONE EXISTS -- ignoring request'
    end

    private

    def appraise_repo(gitrepo, folder_name, project)
      contributions = CodePraise::Mapper::Contributions.new(gitrepo)
      folder_contributions = contributions.for_folder(folder_name)
      commit_contributions = contributions.commits
      appraisal = CodePraise::Value::ProjectFolderContributions
        .new(project, folder_contributions, commit_contributions)
      store_appraisal(appraisal)
    end

    def store_appraisal(appraisal)
      CodePraise::Repository::Appraisal.create(appraisal_hash(appraisal))
    end

    def appraisal_hash(appraisal)
      CodePraise::Representer::ProjectFolderContributions
        .new(appraisal).yield_self do |appraisal_representer|
          JSON.parse(appraisal_representer.to_json)
        end
    end

    def setup_job(request)
      clone_request = CodePraise::Representer::CloneRequest
        .new(OpenStruct.new).from_json(request)

      [clone_request.project,
       ProgressReporter.new(Worker.config, clone_request.id),
       clone_request.folder_name]
    end

    def each_second(seconds)
      seconds.times do
        sleep(1)
        yield if block_given?
      end
    end
  end
end
