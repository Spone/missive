require "test_helper"

module Missive
  class Postmark::WebhooksDeliveryTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @routes = Engine.routes
      @headers = {"HTTP_X_POSTMARK_SECRET" => Rails.application.credentials.postmark.webhooks_secret}
      @dispatch = missive_dispatches(:john_first_newsletter)
    end

    test "receive delivery payload" do
      @payload = {
        "RecordType" => "Delivery",
        "MessageID" => @dispatch.postmark_message_id,
        "Recipient" => @dispatch.subscriber.email,
        "DeliveredAt" => "2025-09-14T16:30:00.0000000Z",
        "Details" => "Test delivery webhook details",
        "Tag" => "welcome-email",
        "ServerID" => 23,
        "Metadata" => {
          "example" => "value",
          "example_2" => "value"
        },
        "MessageStream" => "bulk"
      }

      action
      assert_equal 200, status
      @dispatch.reload
      assert @dispatch.delivered?
      assert_equal Time.utc(2025, 9, 14, 16, 30), @dispatch.delivered_at
    end

    test "receive nonexistent recipient" do
      @payload = {
        "RecordType" => "Delivery",
        "MessageID" => @dispatch.postmark_message_id,
        "Recipient" => "fake@example.com",
        "DeliveredAt" => "2025-09-14T16:30:00.0000000Z"
      }

      action
      assert_equal 404, status
      assert_match "Missive::Subscriber not found", response.body
    end

    test "receive nonexistent dispatch" do
      @payload = {
        "RecordType" => "Delivery",
        "MessageID" => "WRONG",
        "Recipient" => "jane@example.com",
        "DeliveredAt" => "2025-09-14T16:30:00.0000000Z"
      }

      action
      assert_equal 404, status
      assert_match "Missive::Dispatch not found", response.body
    end

    test "receive recipient not matching dispatch" do
      @payload = {
        "RecordType" => "Delivery",
        "MessageID" => @dispatch.postmark_message_id,
        "Recipient" => "jane@example.com",
        "DeliveredAt" => "2025-09-14T16:30:00.0000000Z"
      }

      action
      assert_equal 400, status
      assert_match "Dispatch subscriber #{@dispatch.subscriber.email} does not match payload recipient jane@example.com", response.body
    end

    private

    def action
      post postmark_webhooks_path, headers: @headers, env: {RAW_POST_DATA: @payload.to_json}
    end
  end
end
