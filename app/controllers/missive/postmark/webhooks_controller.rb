module Missive
  class Postmark::WebhooksController < ApplicationController
    skip_forgery_protection

    before_action :verify_webhook
    before_action :set_payload, only: :receive
    before_action :set_customer, only: :receive

    def receive
      case @payload
      in {RecordType: "SubscriptionChange", ChangedAt: changed_at, SuppressSending: true, SuppressionReason: "HardBounce"}
        # @customer.update!(bounced_at: changed_at, disabled_at: Time.current)
      in {RecordType: "SubscriptionChange", ChangedAt: changed_at, SuppressSending: true, SuppressionReason: "SpamComplaint"}
        # @customer.update!(complained_at: changed_at, disabled_at: Time.current)
      in {RecordType: "SubscriptionChange", ChangedAt: changed_at, SuppressSending: true, SuppressionReason: "ManualSuppression"}
        # @customer.update!(unsubscribed_at: changed_at, disabled_at: Time.current)
      in {RecordType: "SubscriptionChange", ChangedAt: changed_at, SuppressSending: false}
        # @customer.update!(disabled_at: nil, unsubscribed_at: nil, complained_at: nil, bounced_at: nil)
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

    def set_customer
      # @customer = Customer.find_by!(email: @payload[:Recipient])
    end

    def webhooks_secret
      Rails.application.credentials.postmark.webhooks_secret
    end
  end
end
