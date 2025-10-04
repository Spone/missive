require 'test_helper'

module Missive
  class Postmark::WebhooksDeliveryTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @routes = Engine.routes
      @headers = { 'HTTP_X_POSTMARK_SECRET' => Rails.application.credentials.postmark.webhooks_secret }
      @message = missive_messages(:one)
    end

    test 'receive delivery payload' do
      @payload = {
        'RecordType' => 'Delivery',
        'MessageID' => @message.message_id,
        'Recipient' => @message.subscriber.email,
        'DeliveredAt' => '2025-09-14T16:30:00.0000000Z',
        'Details' => 'Test delivery webhook details',
        'Tag' => 'welcome-email',
        'ServerID' => 23,
        'Metadata' => {
          'example' => 'value',
          'example_2' => 'value'
        },
        'MessageStream' => 'outbound'
      }

      action
      assert_equal 200, status
      @message.reload
      assert @message.delivered?
      assert_equal Time.utc(2025, 9, 14, 16, 30), @message.delivered_at
    end

    test 'receive nonexistent message' do
      @payload = {
        'RecordType' => 'Delivery',
        'MessageID' => 'WRONG'
      }

      action
      assert_equal 404, status
    end

    test 'receive recipient not matching message' do
      @payload = {
        'RecordType' => 'Delivery',
        'MessageID' => @message.message_id,
        'Recipient' => 'wrong@example.com'
      }

      action
      assert_equal 400, status
    end

    private

    def action
      post postmark_webhooks_path, headers: @headers, env: { RAW_POST_DATA: @payload.to_json }
    end
  end
end
