module Missive
  class Postmark::WebhooksController < ApplicationController
    skip_forgery_protection

    before_action :verify_webhook
    before_action :set_payload, only: :receive
    before_action :set_subscriber, only: :receive

    def receive
      case @payload
      in {RecordType: "SubscriptionChange", ChangedAt: changed_at, SuppressSending: true, SuppressionReason: suppression_reason}
        @subscriber.update!(suppressed_at: changed_at, suppression_reason: suppression_reason.underscore)
      in {RecordType: "SubscriptionChange", ChangedAt: changed_at, SuppressSending: false}
        @subscriber.update!(suppressed_at: nil, suppression_reason: nil)
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
      @subscriber = Subscriber.find_by!(email: @payload[:Recipient])
    end

    def webhooks_secret
      Rails.application.credentials.postmark.webhooks_secret
    end
  end
end
