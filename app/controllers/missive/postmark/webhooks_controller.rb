module Missive
  class Postmark::WebhooksController < ApplicationController
    skip_forgery_protection

    class RecipientNotMatching < StandardError; end

    before_action :verify_webhook
    before_action :set_payload, only: :receive

    def receive
      case @payload
      in { RecordType: 'Delivery', DeliveredAt: delivered_at }
        set_message
        set_subscriber
        check_message_recipient!
        @message.update!(delivered_at:)
      in { RecordType: 'SubscriptionChange', ChangedAt: suppressed_at, SuppressSending: true, SuppressionReason: suppression_reason }
        set_subscriber
        @subscriber.update!(suppressed_at:, suppression_reason: suppression_reason.underscore)
      in { RecordType: 'SubscriptionChange', SuppressSending: false }
        set_subscriber
        @subscriber.update!(suppressed_at: nil, suppression_reason: nil)
      end

      head :ok
    end

    private

    def verify_webhook
      secret_header = request.headers['HTTP_X_POSTMARK_SECRET']

      head :unauthorized if secret_header != webhooks_secret
    end

    def set_payload
      @payload = JSON.parse(request.body.read).with_indifferent_access
    end

    def set_message
      @message = Message.find_by(postmark_message_id: @payload[:MessageID])
    end

    def set_subscriber
      @subscriber = Subscriber.find_by!(email: @payload[:Recipient])
    end

    def check_message_recipient!
      return unless @message.subscriber != @subscriber

      raise RecipientNotMatching,
            "Message subscriber #{@message.subscriber.email} does not match payload recipient #{@payload[:Recipient]}"
    end

    def webhooks_secret
      Rails.application.credentials.postmark.webhooks_secret
    end
  end
end
