require 'test_helper'

module Missive
  class Postmark::WebhooksTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @routes = Engine.routes
      @headers = { 'HTTP_X_POSTMARK_SECRET' => Rails.application.credentials.postmark.webhooks_secret }
      @subscriber = missive_subscribers(:john)
    end

    test 'receive nonexistent recipient' do
      @payload = { 'Recipient' => 'fake@example.com' }

      action
      assert_equal 404, status
    end

    test 'receive wrong payload' do
      @payload = { 'foo' => 'bar', 'Recipient' => @subscriber.email }

      assert_raise NoMatchingPatternError do
        action
      end
    end

    test 'receive wrong secret' do
      @payload = { 'key' => 'value' }
      @headers = { 'HTTP_X_POSTMARK_SECRET' => 'WRONG' }

      action
      assert_equal 401, status
    end

    private

    def action
      post postmark_webhooks_path, headers: @headers, env: { RAW_POST_DATA: @payload.to_json }
    end
  end
end
