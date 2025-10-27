require "test_helper"

module Missive
  module Stamp
    class ApiClient
      class DeliverInBulkTest < ActiveSupport::TestCase
        def message_hash
          {
            from: "david@example.com",
            subject: "Hey {{name}}",
            html_body: "<p>Hello, {{name}}!</p>",
            text_body: "Hello, {{name}}!",
            messages: [
              {
                to: "jane.doe@example.com",
                template_model: {name: "Jane"}
              },
              {
                to: "john.doe@example.com",
                template_model: {name: "John"}
              }
            ]
          }
        end

        def email
          ::Postmark::MessageHelper.to_postmark(message_hash)
        end

        def subject
          api_client.deliver_in_bulk(message_hash)
        end

        def response
          {
            ID: "f24af63c-533d-4b7a-ad65-4a7b3202d3a7",
            Status: "Accepted",
            SubmittedAt: "2024-03-17T07:25:01.4178645-05:00"
          }
        end

        setup do
          stub_request(:post, "https://api.postmarkapp.com/email/bulk")
            .with(body: email.to_json)
            .to_return_json(body: response, status: 200)
        end

        test "converts message hash to Postmark format and posts it to expected endpoint" do
          assert subject
        end

        test "converts response to ruby format" do
          assert_includes subject.keys, :id
        end

        private

        def api_client
          @api_client ||= ApiClient.new(api_token)
        end

        delegate :http_client, to: :api_client

        def api_token
          "provided-api-token"
        end
      end
    end
  end
end
