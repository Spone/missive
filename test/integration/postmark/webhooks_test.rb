require "test_helper"

module Missive
  class Postmark::WebhooksTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @routes = Engine.routes
      @headers = {"HTTP_X_POSTMARK_SECRET" => Rails.application.credentials.postmark.webhooks_secret}
      @subscriber = missive_subscribers(:john)
    end

    test "receive bounce payload" do
      @payload = {
        "RecordType" => "SubscriptionChange",
        "MessageID" => "00000000-0000-0000-0000-000000000000",
        "ServerID" => 23,
        "MessageStream" => "bulk",
        "ChangedAt" => "2025-03-29T20:49:48Z",
        "Recipient" => @subscriber.email,
        "Origin" => "Recipient",
        "SuppressSending" => true,
        "SuppressionReason" => "HardBounce",
        "Tag" => "welcome-email",
        "Metadata" => {
          "example" => "value",
          "example_2" => "value"
        }
      }

      action
      assert_equal 200, status
      @subscriber.reload
      assert @subscriber.suppressed?
      assert @subscriber.hard_bounce?
    end

    test "receive spam complaint payload" do
      @payload = {
        "RecordType" => "SubscriptionChange",
        "MessageID" => "00000000-0000-0000-0000-000000000000",
        "ServerID" => 23,
        "MessageStream" => "bulk",
        "ChangedAt" => "2025-03-29T20:49:48Z",
        "Recipient" => @subscriber.email,
        "Origin" => "Recipient",
        "SuppressSending" => true,
        "SuppressionReason" => "SpamComplaint",
        "Tag" => "welcome-email",
        "Metadata" => {
          "example" => "value",
          "example_2" => "value"
        }
      }

      action
      assert_equal 200, status
      @subscriber.reload
      assert @subscriber.suppressed?
      assert @subscriber.spam_complaint?
    end

    test "receive manual suppression payload" do
      @payload = {
        "RecordType" => "SubscriptionChange",
        "MessageID" => "00000000-0000-0000-0000-000000000000",
        "ServerID" => 23,
        "MessageStream" => "bulk",
        "ChangedAt" => "2025-03-29T20:49:48Z",
        "Recipient" => @subscriber.email,
        "Origin" => "Recipient",
        "SuppressSending" => true,
        "SuppressionReason" => "ManualSuppression",
        "Tag" => "welcome-email",
        "Metadata" => {
          "example" => "value",
          "example_2" => "value"
        }
      }

      action
      assert_equal 200, status
      @subscriber.reload
      assert @subscriber.suppressed?
      assert @subscriber.manual_suppression?
    end

    test "receive resubscription payload" do
      @subscriber = missive_subscribers(:jane)
      @payload = {
        "RecordType" => "SubscriptionChange",
        "MessageID" => "00000000-0000-0000-0000-000000000000",
        "ServerID" => 23,
        "MessageStream" => "bulk",
        "ChangedAt" => "2025-03-29T20:49:48Z",
        "Recipient" => @subscriber.email,
        "Origin" => "Recipient",
        "SuppressSending" => false,
        "SuppressionReason" => "ManualSuppression",
        "Tag" => "welcome-email",
        "Metadata" => {
          "example" => "value",
          "example_2" => "value"
        }
      }

      action
      assert_equal 200, status
      @subscriber.reload
      assert_not @subscriber.suppressed?
      assert_nil @subscriber.suppression_reason
    end

    test "receive nonexistent recipient" do
      @payload = {"Recipient" => "fake@example.com"}

      action
      assert_equal 404, status
    end

    test "receive wrong payload" do
      @payload = {"foo" => "bar", "Recipient" => @subscriber.email}

      assert_raise NoMatchingPatternError do
        action
      end
    end

    test "receive wrong secret" do
      @payload = {"key" => "value"}
      @headers = {"HTTP_X_POSTMARK_SECRET" => "WRONG"}

      action
      assert_equal 401, status
    end

    private

    def action
      post postmark_webhooks_path, headers: @headers, env: {RAW_POST_DATA: @payload.to_json}
    end
  end
end
