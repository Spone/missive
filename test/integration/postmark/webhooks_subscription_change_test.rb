require "test_helper"

module Missive
  class Postmark::WebhooksSubscriptionChangeTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @routes = Engine.routes
      @headers = {"HTTP_X_POSTMARK_SECRET" => Rails.application.credentials.postmark.webhooks_secret}
      @subscriber = missive_subscribers(:john)
      @subscription = missive_subscriptions(:john_newsletter)
      @dispatch = missive_dispatches(:john_first_newsletter)
    end

    test "receive bounce payload" do
      @payload = {
        "RecordType" => "SubscriptionChange",
        "MessageID" => @dispatch.postmark_message_id,
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
      [@subscriber, @subscription, @dispatch].each do |record|
        record.reload
        assert record.suppressed?
        assert record.hard_bounce?
      end
    end

    test "receive spam complaint payload" do
      @payload = {
        "RecordType" => "SubscriptionChange",
        "MessageID" => @dispatch.postmark_message_id,
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
      [@subscriber, @subscription, @dispatch].each do |record|
        record.reload
        assert record.suppressed?
        assert record.spam_complaint?
      end
    end

    test "receive manual suppression payload" do
      @payload = {
        "RecordType" => "SubscriptionChange",
        "MessageID" => @dispatch.postmark_message_id,
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
      [@subscriber, @subscription, @dispatch].each do |record|
        record.reload
        assert record.suppressed?
        assert record.manual_suppression?
      end
    end

    test "receive manual suppression from admin payload" do
      @payload = {
        "RecordType" => "SubscriptionChange",
        # MessageID is null for Manual Suppressions with Origin value of Customer or Admin and Reactivations.
        "MessageID" => nil,
        "ServerID" => 23,
        "MessageStream" => "bulk",
        "ChangedAt" => "2025-03-29T20:49:48Z",
        "Recipient" => @subscriber.email,
        "Origin" => "Admin",
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
      assert_not @subscription.suppressed?
      assert_not @dispatch.suppressed?
    end

    test "receive resubscription payload" do
      @subscriber = missive_subscribers(:jane)
      @subscription = missive_subscriptions(:jane_newsletter)
      @dispatch = missive_dispatches(:jane_first_newsletter)
      @payload = {
        "RecordType" => "SubscriptionChange",
        "MessageID" => @dispatch.postmark_message_id,
        "ServerID" => 23,
        "MessageStream" => "bulk",
        "ChangedAt" => "2025-03-29T20:49:48Z",
        "Recipient" => @subscriber.email,
        "Origin" => "Recipient",
        "SuppressSending" => false,
        # The SuppressionReason and Tag fields are null, while the Metadata field is an empty object when SuppressSending = false (reactivation).
        "SuppressionReason" => nil,
        "Tag" => nil,
        "Metadata" => {}
      }

      action
      assert_equal 200, status
      [@subscriber, @subscription, @dispatch].each do |record|
        record.reload
        assert_not record.suppressed?
        assert_nil record.suppression_reason
      end
    end

    test "receive nonexistent recipient" do
      @payload = {
        "RecordType" => "SubscriptionChange",
        "Recipient" => "fake@example.com",
        "SuppressSending" => false,
        "SuppressionReason" => "ManualSuppression"
      }

      action
      assert_equal 404, status
      assert_match "Missive::Subscriber not found", response.body
    end

    private

    def action
      post postmark_webhooks_path, headers: @headers, env: {RAW_POST_DATA: @payload.to_json}
    end
  end
end
