require "test_helper"

module Missive
  class Postmark::WebhooksOpenTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @routes = Engine.routes
      @headers = {"HTTP_X_POSTMARK_SECRET" => Rails.application.credentials.postmark.webhooks_secret}
      @dispatch = missive_dispatches(:john_first_newsletter)
    end

    test "receive open payload" do
      @payload = {
        "RecordType" => "Open",
        "MessageStream" => "bulk",
        "FirstOpen" => true,
        "Client" => {
          "Name" => "Chrome 35.0.1916.153",
          "Company" => "Google",
          "Family" => "Chrome"
        },
        "OS" => {
          "Name" => "OS X 10.7 Lion",
          "Company" => "Apple Computer, Inc.",
          "Family" => "OS X 10"
        },
        "Platform" => "WebMail",
        "UserAgent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36",
        "Geo" => {
          "CountryISOCode" => "RS",
          "Country" => "Serbia",
          "RegionISOCode" => "VO",
          "Region" => "Autonomna Pokrajina Vojvodina",
          "City" => "Novi Sad",
          "Zip" => "21000",
          "Coords" => "45.2517,19.8369",
          "IP" => "188.2.95.4"
        },
        "MessageID" => @dispatch.postmark_message_id,
        "Metadata" => {
          "example" => "value",
          "example_2" => "value"
        },
        "ReceivedAt" => "2025-09-14T16:30:00.0000000Z",
        "Tag" => "welcome-email",
        "Recipient" => @dispatch.subscriber.email
      }

      action
      assert_equal 200, status
      @dispatch.reload
      assert @dispatch.opened?
      assert_equal Time.utc(2025, 9, 14, 16, 30), @dispatch.opened_at
    end

    test "receive nonexistent recipient" do
      @payload = {
        "RecordType" => "Open",
        "MessageID" => @dispatch.postmark_message_id,
        "Recipient" => "fake@example.com",
        "ReceivedAt" => "2025-09-14T16:30:00.0000000Z"
      }

      action
      assert_equal 404, status
      assert_match "Missive::Subscriber not found", response.body
    end

    test "receive nonexistent dispatch" do
      @payload = {
        "RecordType" => "Open",
        "MessageID" => "WRONG",
        "Recipient" => "jane@example.com",
        "ReceivedAt" => "2025-09-14T16:30:00.0000000Z"
      }

      action
      assert_equal 404, status
      assert_match "Missive::Dispatch not found", response.body
    end

    test "receive recipient not matching dispatch" do
      @payload = {
        "RecordType" => "Open",
        "MessageID" => @dispatch.postmark_message_id,
        "Recipient" => "jane@example.com",
        "ReceivedAt" => "2025-09-14T16:30:00.0000000Z"
      }

      action
      assert_equal 400, status
      assert_match "Dispatch subscriber #{@dispatch.subscriber.email} does not match payload recipient jane@example.com",
        response.body
    end

    private

    def action
      post postmark_webhooks_path, headers: @headers, env: {RAW_POST_DATA: @payload.to_json}
    end
  end
end
