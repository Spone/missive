require "test_helper"

module Missive
  module Stamp
    class ApiClient
      class DeliverMessageInBulkTest < ActiveSupport::TestCase
        def id
          "f24af63c-533d-4b7a-ad65-4a7b3202d3a7"
        end

        def mail
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

        def subject
          api_client.deliver_message_in_bulk(mail, recipients)
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

        test "posts to expected endpoint" do
          assert subject
        end

        test "converts response to ruby format" do
          assert_equal id, subject[:id]
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
