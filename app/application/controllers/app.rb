# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'

module Floofloo
  # Web App
  class App < Roda # rubocop:disable Metrics/ClassLength
    plugin :halt
    plugin :all_verbs # recognizes HTTP verbs beyond GET/POST (e.g., DELETE)
    use Rack::MethodOverride # for other HTTP verbs (with plugin all_verbs)

    route do |routing| # rubocop:disable Metrics/BlockLength
      # GET /
      routing.root do
        message = "Floofloo API v1 at /api/v1/ in #{App.environment} mode"

        result_response = Representer::HttpResponse.new(
          Response::ApiResult.new(status: :ok, message: message)
        )

        response.status = result_response.http_status_code
        result_response.to_json
      end

      routing.on 'api/v1' do # rubocop:disable Metrics/BlockLength
        routing.on 'issue' do # rubocop:disable Metrics/BlockLength
          routing.on String do |issue_name| # rubocop:disable Metrics/BlockLength
            routing.on 'event' do # rubocop:disable Metrics/BlockLength
              routing.on String do |event_name| # rubocop:disable Metrics/BlockLength
                routing.on 'news' do # rubocop:disable Metrics/BlockLength
                  # GET /issue/{issue_name}/event/{event_name}/news
                  routing.get do
                    find_news = Services::GetNews.new.call(event_name: event_name)

                    if find_news.failure?
                      failed = Representer::HttpResponse.new(find_news.failure)
                      routing.halt failed.http_status_code, failed.to_json
                    end

                    http_response = Representer::HttpResponse.new(find_news.value!)
                    response.status = http_response.http_status_code

                    Representer::NewsList.new(find_news.value!.message).to_json
                  rescue StandardError => e
                    puts e.full_message

                    routing.redirect '/'
                  end

                  # POST /issue/{issue_name}/event/{event_name}/news
                  routing.post do
                    add_news = Services::AddNews.new.call(event_name: event_name)

                    if add_news.failure?
                      failed = Representer::HttpResponse.new(add_news.failure)
                      routing.halt failed.http_status_code, failed.to_json
                    end

                    http_response = Representer::HttpResponse.new(add_news.value!)
                    response.status = http_response.http_status_code

                    Representer::NewsList.new(add_news.value!.message).to_json
                  rescue StandardError => e
                    puts e.full_message

                    routing.redirect '/'
                  end
                end

                routing.on 'donations' do # rubocop:disable Metrics/BlockLength
                  # GET /issue/{issue_name}/event/{event_name}/donations
                  routing.get do
                    find_donations = Services::GetDonation.new.call(event_name: event_name)

                    if find_donations.failure?
                      failed = Representer::HttpResponse.new(find_donations.failure)
                      routing.halt failed.http_status_code, failed.to_json
                    end

                    http_response = Representer::HttpResponse.new(find_donations.value!)
                    response.status = http_response.http_status_code

                    Representer::DonationsList.new(find_donations.value!.message).to_json
                  rescue StandardError => e
                    puts e.message

                    routing.redirect '/'
                  end

                  # POST /issue/{issue_name}/event/{event_name}/donations
                  routing.post do
                    add_donation = Services::AddDonation.new.call(event_name: event_name)

                    if add_donation.failure?
                      failed = Representer::HttpResponse.new(add_donation.failure)
                      routing.halt failed.http_status_code, failed.to_json
                    end

                    http_response = Representer::HttpResponse.new(add_donation.value!)
                    response.status = http_response.http_status_code

                    Representer::DonationsList.new(add_donation.value!.message).to_json
                  rescue StandardError => e
                    puts e.message

                    routing.redirect '/'
                  end
                end

                # POST /issue/{issue_name}/event/{event_name}
                routing.post do
                  add_event = Services::AddEvent.new.call(issue_name: issue_name, event_name: event_name)

                  if add_event.failure?
                    failed = Representer::HttpResponse.new(add_event.failure)
                    routing.halt failed.http_status_code, failed.to_json
                  end

                  http_response = Representer::HttpResponse.new(add_event.value!)
                  response.status = http_response.http_status_code
                  Representer::Event.new(add_event.value!.message).to_json
                rescue StandardError => e
                  puts e.message

                  routing.redirect '/'
                end
              end
            end

            # POST /issue/{issue_name}
            routing.post do
              add_issue = Services::AddIssue.new.call(issue_name: issue_name)

              if add_issue.failure?
                failed = Representer::HttpResponse.new(add_issue.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(add_issue.value!)
              response.status = http_response.http_status_code
              Representer::Issue.new(add_issue.value!.message).to_json
            end
          end
        end
      end
    end
  end
end