module Missive
  class Postmark::WebhooksController < ApplicationController
    skip_forgery_protection

    class RecipientNotMatching < StandardError; end

    before_action :verify_webhook
    before_action :set_payload, only: :receive

    rescue_from RecipientNotMatching, with: :handle_bad_request
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from NoMatchingPatternError, with: :handle_no_matching_pattern

    def receive
      case @payload
      in {RecordType: "Delivery", DeliveredAt: delivered_at}
        set_subscriber! && set_dispatch! && check_dispatch_recipient!
        @dispatch.update!(delivered_at:)
      in {RecordType: "SubscriptionChange", ChangedAt: suppressed_at, SuppressSending: true, SuppressionReason: suppression_reason}
        set_subscriber! && set_dispatch && set_subscription
        reason = suppression_reason.underscore
        @subscriber.suppress!(reason:)
        @dispatch&.suppress!(reason:)
        @subscription&.suppress!(reason:)
      in {RecordType: "SubscriptionChange", SuppressSending: false}
        set_subscriber! && set_dispatch && set_subscription
        @subscriber.unsuppress!
        @dispatch&.unsuppress!
        @subscription&.unsuppress!
      end

      head :ok
    end

    private

    def verify_webhook
      secret_header = request.headers["HTTP_X_POSTMARK_SECRET"]

      render plain: "Cannot verify webhook", status: :unauthorized if secret_header != webhooks_secret
    end

    def set_payload
      @payload = JSON.parse(request.body.read).with_indifferent_access
    end

    def set_dispatch
      @dispatch = Dispatch.includes(:subscriber, :list).find_by(postmark_message_id: @payload["MessageID"])
    end

    def set_dispatch!
      @dispatch = Dispatch.includes(:subscriber, :list).find_by!(postmark_message_id: @payload["MessageID"])
    end

    def set_subscriber!
      @subscriber = Subscriber.find_by!(email: @payload["Recipient"])
    end

    def set_subscription
      return if @dispatch.nil?

      list = @dispatch.list
      @subscription = Subscription.find_by(list:, subscriber: @subscriber)
    end

    def check_dispatch_recipient!
      return unless @dispatch.subscriber != @subscriber

      raise RecipientNotMatching,
        "Dispatch subscriber #{@dispatch.subscriber.email} does not match payload recipient #{@payload["Recipient"]}"
    end

    def webhooks_secret
      Rails.application.credentials.postmark.webhooks_secret
    end

    def handle_bad_request(e)
      render plain: e.message, status: :bad_request
    end

    def handle_not_found(e)
      render plain: "#{e.model} not found", status: :not_found
    end

    def handle_no_matching_pattern
      render plain: "Webhook payload not supported", status: :unprocessable_entity
    end
  end
end
