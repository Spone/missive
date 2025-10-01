require "test_helper"

module Missive
  class Postmark::WebhooksTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @routes = Engine.routes
    end

    def test_receive_bounce_payload
      @payload = {
        "RecordType" => "SubscriptionChange",
        "MessageID" => "00000000-0000-0000-0000-000000000000",
        "ServerID" => 23,
        "MessageStream" => "outbound",
        "ChangedAt" => "2025-03-29T20:49:48Z",
        "Recipient" => "john@example.com",
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
      # TODO: more assertions
    end

    def test_receive_spam_complaint_payload
      @payload = {
        "RecordType" => "SubscriptionChange",
        "MessageID" => "00000000-0000-0000-0000-000000000000",
        "ServerID" => 23,
        "MessageStream" => "outbound",
        "ChangedAt" => "2025-03-29T20:49:48Z",
        "Recipient" => "john@example.com",
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
      # TODO: more assertions
    end

    def test_receive_manual_suppression_payload
      @payload = {
        "RecordType" => "SubscriptionChange",
        "MessageID" => "00000000-0000-0000-0000-000000000000",
        "ServerID" => 23,
        "MessageStream" => "outbound",
        "ChangedAt" => "2025-03-29T20:49:48Z",
        "Recipient" => "john@example.com",
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
      # TODO: more assertions
    end

    def test_receive_resubscription_payload
      @payload = {
        "RecordType" => "SubscriptionChange",
        "MessageID" => "00000000-0000-0000-0000-000000000000",
        "ServerID" => 23,
        "MessageStream" => "outbound",
        "ChangedAt" => "2025-03-29T20:49:48Z",
        "Recipient" => "john@example.com",
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
      # TODO: more assertions
    end

    def test_receive_wrong_payload
      @payload = {"key" => "value"}

      assert_raise NoMatchingPatternError do
        action
      end
    end

    private

    def action
      post postmark_webhooks_path, headers:, env: {RAW_POST_DATA: @payload.to_json}
    end

    def headers
      {"HTTP_X_POSTMARK_SECRET" => Rails.application.credentials.postmark.webhooks_secret}
    end
  end
end
