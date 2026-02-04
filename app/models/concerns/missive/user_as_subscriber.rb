module Missive
  module UserAsSubscriber
    extend ActiveSupport::Concern

    class AssociationAlreadyDefinedError < StandardError; end

    ASSOCIATION_NAMES = %i[subscriber dispatches subscriptions subscribed_lists unsubscribed_lists].freeze

    class_methods do
      def missive_subscriber_config
        @missive_subscriber_config ||= ASSOCIATION_NAMES.index_with { |name| name }
      end

      def configure_missive_subscriber(options = {})
        missive_subscriber_config.merge!(options)
        _define_missive_subscriber_associations
      end

      def _define_missive_subscriber_associations
        config = missive_subscriber_config

        _check_missive_association_collision!(config[:subscriber])

        has_one config[:subscriber], class_name: "Missive::Subscriber", foreign_key: :user_id, dependent: :destroy
        has_many config[:dispatches], class_name: "Missive::Dispatch", through: config[:subscriber]
        has_many config[:subscriptions], class_name: "Missive::Subscription", through: config[:subscriber]
        has_many config[:subscribed_lists], class_name: "Missive::List", through: config[:subscriber], source: :lists
        has_many config[:unsubscribed_lists], -> { where.not(missive_subscriptions: {suppressed_at: nil}) },
          class_name: "Missive::List",
          through: config[:subscriber],
          source: :lists
      end

      def _check_missive_association_collision!(name)
        return unless reflect_on_association(name)

        raise AssociationAlreadyDefinedError,
          "Association :#{name} is already defined on #{self.name}. " \
          "Use configure_missive_subscriber to specify a different name. " \
          "Example: configure_missive_subscriber(subscriber: :missive_subscriber)"
      end
    end

    included do
      _define_missive_subscriber_associations

      def init_subscriber(attributes = {})
        assoc = self.class.missive_subscriber_config[:subscriber]
        send("#{assoc}=", Missive::Subscriber.find_or_initialize_by(email:))
        send(assoc).assign_attributes(attributes)
        send(assoc).save!
        send(assoc)
      end
    end
  end
end
