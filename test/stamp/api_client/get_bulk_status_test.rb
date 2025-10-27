require "test_helper"

module Missive
  module Stamp
    class ApiClient
      class GetBulkStatusTest < ActiveSupport::TestCase
        def id
          "f24af63c-533d-4b7a-ad65-4a7b3202d3a7"
        end

        def subject
          api_client.get_bulk_status(id)
        end

        def response
          {
            Id: id,
            SubmittedAt: "2024-07-22T15:39:49.3723691Z",
            TotalMessages: 2,
            PercentageCompleted: 2,
            Status: "Completed",
            Subject: "Hey {{name}}"
          }
        end

        setup do
          stub_request(:get, "https://api.postmarkapp.com/email/bulk/#{id}")
            .to_return_json(body: response, status: 200)
        end

        test "requests the bulk status from the expected endpoint" do
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
