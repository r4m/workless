require 'delayed_job'

module Delayed
  module Workless
    module Scaler
  
      class Base
        def self.jobs
          if Rails.version >= "3.0.0"
            Delayed::Job.where(:failed_at => nil)
          else
            Delayed::Job.all(:conditions => { :failed_at => nil })
          end
        end
      end

      module HerokuClient

        def client
          @client ||= ::Heroku::API.new(:api_key => ENV['HEROKU_API_KEY'])
        end

        def rescue_heroku_errors
          yield
        rescue ::Heroku::API::Errors::NilApp, ::Heroku::API::Errors::Unauthorized => e
          if defined?(Rollbar)
            Rollbar.report_exception(e)
            Rails.logger.error "WORKLESS error. Reported to Rollbar the following exception: " + e.inspect
          else
            Rails.logger.error "WORKLESS error. Exception: " + e.inspect
          end
        end

      end

    end
  end
end
