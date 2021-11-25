# frozen_string_literal: true

require_relative '../init.rb'
require_relative 'progress_reporter.rb'
require_relative 'project_clone.rb'
require_relative 'cache_state.rb'
require_relative 'appraisal_service'
require 'econfig'
require 'shoryuken'

MUTEX = Mutex.new

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
    # Shoryuken.sqs_client_receive_message_opts = { max_number_of_messages: 1 }
    shoryuken_options queue: config.CLONE_QUEUE_URL, auto_visibility_timeout: true

    def perform(sqs_msg, request)
      project, reporter, request_id, update = setup_job(request)
      gitrepo = CodePraise::GitRepo.new(project, Worker.config)
      service = Service.new(project, reporter, gitrepo, request_id)
      cache = service.find_or_init_cache(project.name, project.owner.username)

      service.setup_channel_id(request_id.to_s) unless cache.request_id

      cache_state = CacheState.new(cache)
      cache_state.update_state('init') if update

      if cache_state.cloning?
        service.switch_channel(cache.request_id)
      else
        cache_state.update_state('cloning')
        service.clone_project
        cache_state.update_state('cloned')
      end

      if cache_state.cloned? && !cache_state.appraising?
        MUTEX.synchronize do
          puts "appraise #{gitrepo.id}"
          cache_state.update_state('appraising')
          service.appraise_project
          cache_state.update_state('appraised')
          puts "done #{gitrepo.id}}"
        end
      else
        service.switch_channel(cache.request_id)
      end

      if cache_state.appraised? && !cache_state.stored?
        service.store_appraisal_cache
        cache_state.update_state('stored')
      else
        service.switch_channel(cache.request_id)
      end

      sqs_msg.delete
    rescue => e
      puts e.full_message
      cache_state.back(gitrepo)
    end

    private

    def setup_job(request)
      clone_request = CodePraise::Representer::CloneRequest
        .new(OpenStruct.new).from_json(request)

      [clone_request.project,
       ProgressReporter.new(Worker.config, clone_request.id),
       clone_request.id, clone_request.update]
    end
  end
end
