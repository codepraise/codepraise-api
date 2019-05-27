# frozen_string_literal: true

require 'rack/cache'
require 'redis-rack-cache'
require 'roda'
require 'econfig'
require 'mongo'
require 'shoryuken'

module CodePraise
  # Environment-specific configuration
  class Api < Roda
    plugin :environments

    extend Econfig::Shortcut
    Econfig.env = environment.to_s
    Econfig.root = '.'

    configure :development, :test, :container do
      require 'pry'

      Mongo::Logger.logger.level = Logger::FATAL
      # Shoryuken.logger.level = Logger::FATAL
      # Allows running reload! in pry to restart entire app
      def self.reload!
        exec 'pry -r ./init.rb'
      end
    end

    configure :development, :test, :app_test do
      ENV['DATABASE_URL'] = 'sqlite://' + config.DB_FILENAME
      ENV['MONGODB_URL'] = 'mongodb://' + config.MONGO_URL
    end

    configure :container do
      ENV['DATABASE_URL'] = 'postgres://' + config.DB_URL
      ENV['MONGODB_URL'] = 'mongodb://' + config.MONGO_URL
    end

    configure :development do
      use Rack::Cache,
          verbose: true,
          metastore: 'file:_cache/rack/meta',
          entitystore: 'file:_cache/rack/body'
    end

    configure :production do
      # Use deployment platform's DATABASE_URL environment variable
      puts 'RUNNING IN PRODUCTION MODE'

      use Rack::Cache,
          verbose: true,
          metastore: config.REDISCLOUD_URL + '/0/metastore',
          entitystore: config.REDISCLOUD_URL + '/0/entitystore'
    end

    configure :app_test do
      require_relative '../spec/helpers/vcr_helper.rb'
      VcrHelper.setup_vcr
      VcrHelper.configure_vcr_for_github(recording: :none)
    end

    configure do
      require 'sequel'
      DB = Sequel.connect(ENV['DATABASE_URL'])

      def self.DB # rubocop:disable Naming/MethodName
        DB
      end

      require 'mongo'
      MONGO = Mongo::Client.new(ENV['MONGODB_URL'])

      def self.mongo
        MONGO
      end
    end
  end
end
