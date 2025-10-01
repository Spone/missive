module Missive
  class Postmark::WebhooksController < ApplicationController
    skip_forgery_protection

    before_action :verify_webhook
    before_action :set_payload, only: :receive
    before_action :set_subscriber, only: :receive

    def receive
      case @payload
      in {RecordType: "SubscriptionChange", ChangedAt: changed_at, SuppressSending: true, SuppressionReason: "HardBounce"}
        # @subscriber.update!(bounced_at: changed_at, disabled_at: Time.current)
      in {RecordType: "SubscriptionChange", ChangedAt: changed_at, SuppressSending: true, SuppressionReason: "SpamComplaint"}
        # @subscriber.update!(complained_at: changed_at, disabled_at: Time.current)
      in {RecordType: "SubscriptionChange", ChangedAt: changed_at, SuppressSending: true, SuppressionReason: "ManualSuppression"}
        # @subscriber.update!(unsubscribed_at: changed_at, disabled_at: Time.current)
      in {RecordType: "SubscriptionChange", ChangedAt: changed_at, SuppressSending: false}
        # @subscriber.update!(disabled_at: nil, unsubscribed_at: nil, complained_at: nil, bounced_at: nil)
      end

      head :ok
    end

    private

    def verify_webhook
      secret_header = request.headers["HTTP_X_POSTMARK_SECRET"]

      head :unauthorized if secret_header != webhooks_secret
    end

    def set_payload
      @payload = JSON.parse(request.body.read).with_indifferent_access
    end

    def set_subscriber
      # @subscriber = Customer.find_by!(email: @payload[:Recipient])
    end

    def webhooks_secret
      Rails.application.credentials.postmark.webhooks_secret
    end
  end
end
