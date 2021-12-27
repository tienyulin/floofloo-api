# frozen_string_literal: true

require_relative '../init'

require 'figaro'
require 'shoryuken'

# shoryuken worker class to add donation in parellel
class AddDonationWorker
  # Environment variables setup
  Figaro.application = Figaro::Application.new(
    environment: ENV['RACK_ENV'] || 'development',
    path: File.expand_path('config/secrets.yml')
  )
  Figaro.load
  def self.config() = Figaro.env

  Shoryuken.sqs_client = Aws::SQS::Client.new(
    access_key_id: config.AWS_ACCESS_KEY_ID,
    secret_access_key: config.AWS_SECRET_ACCESS_KEY,
    region: config.AWS_REGION
  )

  include Shoryuken::Worker
  shoryuken_options queue: config.DONATION_QUEUE_URL, auto_delete: true

  def perform(_sqs_msg, request)
    input = JSON.parse(request, :symbolize_names => true)
    event = Floofloo::Repository::IssuesFor.entity(Floofloo::Entity::Event.new(id: nil, name: '')).find_name(input[:event_name])
    donation_result = Floofloo::Donation::DonationMapper
      .new(AddDonationWorker.config.GLOBAL_GIVING_KEY)
      .find(input[:event_name])

    donation_result.each do |donation|
      Floofloo::Repository::DonationFor.entity(donation).create(event, donation)
    end
  rescue StandardError => e
    puts e.message
  end
end
