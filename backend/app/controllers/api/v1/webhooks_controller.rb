

module Api
  module V1
    module Payments
          
      class Api::V1::WebhooksController < ApplicationController
            skip_before_action :verify_authenticity_token

        def receive

              def receive
                data = JSON.parse(request.raw_post) rescue {}

                puts "Webhook recibido:"
                puts data

                head :ok
          
        end
      end
    
    end
  end
end
