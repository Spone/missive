require "test_helper"

module Missive
  module Stamp
    class ApiClient
      class DeliverInBulkTest < ActiveSupport::TestCase
        def id
          "f24af63c-533d-4b7a-ad65-4a7b3202d3a7"
        end

        def message
          Mail.new do
            from "david@example.com"
            subject "Hey {{name}}"
            body "Hello, {{name}}!"
          end
        end

        def recipients
          [
            {
              to: "jane.doe@example.com",
              template_model: {name: "Jane"}
            },
            {
              to: "john.doe@example.com",
              template_model: {name: "John"}
            }
          ]
        end

        def email
          ::Postmark::MessageHelper.to_postmark(message)
        end

        def email_json
          ::Postmark::Json.encode(email)
        end

        def subject
          api_client.deliver_in_bulk(email, recipients)
        end

        def response
          {
            ID: id,
            Status: "Accepted",
            SubmittedAt: "2024-03-17T07:25:01.4178645-05:00"
          }
        end

        setup do
          stub_request(:post, "https://api.postmarkapp.com/email/bulk")
            .to_return_json(body: response, status: 200)
        end

        test "converts message hash to Postmark format and posts it to expected enpoint" do
          assert subject
        end

        test "converts response to ruby format" do
          assert_equal subject[:id], id
        end

        private

        def api_client
          @api_client ||= ApiClient.new(api_token)
        end

        delegate :http_client, to: :api_client

        def api_token
          "POSTMARK_API_TEST"
        end
      end
    end
  end
end
