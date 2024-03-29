# frozen_string_literal: true

require 'rake/testtask'

task :default do
  puts `rake -T`
end

desc 'Run all tests'
Rake::TestTask.new(:spec) do |t|
  puts 'Make sure worker is running in seperate process'
  t.pattern = 'spec/tests/**/*_spec.rb'
  t.warning = false
end

desc 'Keep restarting web app upon changes'
task :rerack do
  sh "rerun -c rackup --ignore 'coverage/*'"
end

namespace :run do
  desc 'Run API in dev mode'
  task :dev do
    sh 'rerun -c "rackup -p 9090"'
  end

  desc 'Run API in test mode'
  task :test do
    sh 'RACK_ENV=test rackup -p 9090'
  end
end

namespace :db do
  task :config do
    require 'sequel'
    require_relative 'config/environment' # load config info
    require_relative 'spec/helpers/database_helper'

    def app() = Floofloo::App
  end

  desc 'Run migrations'
  task migrate: :config do
    Sequel.extension :migration
    puts "Migrating #{app.environment} database to latest"
    Sequel::Migrator.run(app.DB, 'app/infrastructure/database/migrations')
  end

  desc 'Wipe records from all tables'
  task wipe: :config do
    if app.environment == :production
      puts 'Do not damage production database!'
      return
    end

    DatabaseHelper.wipe_database
  end

  desc 'Delete dev or test database file (set correct RACK_ENV)'
  task drop: :config do
    if app.environment == :production
      puts 'Do not damage production database!'
      return
    end

    FileUtils.rm(Floofloo::App.config.DB_FILENAME)
    puts "Deleted #{Floofloo::App.config.DB_FILENAME}"
  end

  desc 'Initial database data'
  task :init do
    puts 'Initial database data'
    sh ' bash app/infrastructure/database/local/data_helper.sh'
  end
end

namespace :cache do
  task :config do
    require_relative 'config/environment' # load config info
    require_relative 'app/infrastructure/cache/init' # load cache client
    @api = Floofloo::App
  end

  desc 'Directory listing of local dev cache'
  namespace :list do
    task :dev do
      puts 'Lists development cache'
      list = `ls _cache/rack/meta`
      puts 'No local cache found' if list.empty?
      puts list
    end

    desc 'Lists production cache'
    task :production => :config do
      puts 'Finding production cache'
      keys = Floofloo::Cache::Client.new(@api.config).keys
      puts 'No keys found' if keys.none?
      keys.each { |key| puts "Key: #{key}" }
    end
  end

  namespace :wipe do
    desc 'Delete development cache'
    task :dev do
      puts 'Deleting development cache'
      sh 'rm -rf _cache/*'
    end

    desc 'Delete production cache'
    task :production => :config do
      print 'Are you sure you wish to wipe the production cache? (y/n) '
      if $stdin.gets.chomp.downcase == 'y'
        puts 'Deleting production cache'
        wiped = Floofloo::Cache::Client.new(@api.config).wipe
        wiped.each_key { |key| puts "Wiped: #{key}" }
      end
    end
  end
end

namespace :queues do
  task :config do
    require 'aws-sdk-sqs'
    require_relative 'config/environment' # load config info
    @api = Floofloo::App
    @sqs = Aws::SQS::Client.new(
      access_key_id: @api.config.AWS_ACCESS_KEY_ID,
      secret_access_key: @api.config.AWS_SECRET_ACCESS_KEY,
      region: @api.config.AWS_REGION
    )
    @q_name = @api.config.QUEUE
    @q_url = @sqs.get_queue_url(queue_name: @q_name).queue_url

    puts "Environment: #{@api.environment}"
  end

  desc 'Create SQS queue for worker'
  task :create => :config do
    @sqs.create_queue(queue_name: @q_name)

    puts 'Queue created:'
    puts " Name: #{@q_name}"
    puts " Region: #{@api.config.AWS_REGION}"
    puts " URL: #{@q_url}"
  rescue StandardError => e
    puts "Error creating queue: #{e}"
  end

  desc 'Report status of queue for worker'
  task :status => :config do
    puts 'Queue info:'
    puts " Name: #{@q_name}"
    puts " Region: #{@api.config.AWS_REGION}"
    puts " URL: #{q_url}"
  rescue StandardError => e
    puts "Error finding queue: #{e}"
  end

  desc 'Purge messages in SQS queue for worker'
  task :purge => :config do
    @sqs.purge_queue(queue_url: @q_url)
    puts "Queue #{@q_name} purged"
  rescue StandardError => e
    puts "Error purging queue: #{e}"
  end
end

namespace :worker do
  namespace :run do
    desc 'Run the background worker in development mode'
    task :dev => :config do
      sh 'RACK_ENV=development bundle exec shoryuken -r ./workers/add_news_worker.rb -C ./workers/shoryuken_news_dev.yml'
    end

    desc 'Run the background worker in testing mode'
    task :test => :config do
      sh 'RACK_ENV=test bundle exec shoryuken -r ./workers/add_news_worker.rb -C ./workers/shoryuken_news_test.yml'
    end

    desc 'Run the background worker in production mode'
    task :production => :config do
      sh 'RACK_ENV=production bundle exec shoryuken -r ./workers/add_news_worker.rb -C ./workers/shoryuken_news_production.yml'
    end
  end
end

namespace :worker_donation do
  namespace :run do
    desc 'Run the background worker in development mode'
    task :dev => :config do
      sh 'RACK_ENV=development bundle exec shoryuken -r ./workers/add_donation_worker.rb -C ./workers/shoryuken_donation_dev.yml'
    end

    desc 'Run the background worker in testing mode'
    task :test => :config do
      sh 'RACK_ENV=test bundle exec shoryuken -r ./workers/add_donation_worker.rb -C ./workers/shoryuken_donation_test.yml'
    end

    desc 'Run the background worker in production mode'
    task :production => :config do
      sh 'RACK_ENV=production bundle exec shoryuken -r ./workers/add_donation_worker.rb -C ./workers/shoryuken_donation_production.yml'
    end
  end
end

desc 'Run application console'
task :console do
  sh 'pry -r ./init'
end

namespace :vcr do
  desc 'Delete cassette fixtures'
  task :wipe do
    sh 'rm spec/fixtures/cassettes/*.yml' do |ok, _|
      puts(ok ? 'Cassettes deleted' : 'No cassettes found')
    end
  end
end

namespace :quality do
  only_app = 'config/ app/'

  desc 'Run all static-analysis quality checks'
  task all: %i[rubocop reek flog]

  desc 'Code style linter'
  task :rubocop do
    sh 'rubocop'
  end

  desc 'Code smell detector'
  task :reek do
    sh 'reek'
  end

  desc 'Complexity analysis'
  task :flog do
    sh "flog -m #{only_app}"
  end
end
