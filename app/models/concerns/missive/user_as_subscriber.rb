module Missive
  module UserAsSubscriber
    extend ActiveSupport::Concern

    class AssociationAlreadyDefinedError < StandardError; end

    DEFAULT_ASSOCIATION_NAMES = {
      subscriber: :missive_subscriber,
      dispatches: :missive_dispatches,
      subscriptions: :missive_subscriptions,
      subscribed_lists: :missive_subscribed_lists,
      unsubscribed_lists: :missive_unsubscribed_lists
    }.freeze

    def self.with(options = {})
      config = DEFAULT_ASSOCIATION_NAMES.merge(options)

      Module.new do
        extend ActiveSupport::Concern

        define_singleton_method(:inspect) { "Missive::UserAsSubscriber.with(#{options.inspect})" }

        included do |base|
          base.instance_variable_set(:@missive_subscriber_config, config)
          base.extend(ClassMethods)
          base.include(InstanceMethods)
          base._define_missive_subscriber_associations
        end
      end
    end

    module ClassMethods
      def missive_subscriber_config
        @missive_subscriber_config ||= DEFAULT_ASSOCIATION_NAMES.dup
      end

      def _define_missive_subscriber_associations
        config = missive_subscriber_config

        _check_missive_association_collision!(config[:subscriber])

        has_one config[:subscriber], class_name: "Missive::Subscriber", foreign_key: :user_id, dependent: :destroy
        has_many config[:dispatches], class_name: "Missive::Dispatch", through: config[:subscriber], source: :dispatches
        has_many config[:subscriptions], class_name: "Missive::Subscription", through: config[:subscriber], source: :subscriptions
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
          "Use Missive::UserAsSubscriber.with to specify a different name. " \
          "Example: include Missive::UserAsSubscriber.with(subscriber: :missive_subscriber)"
      end
    end

    module InstanceMethods
      def init_subscriber(attributes = {})
        assoc = self.class.missive_subscriber_config[:subscriber]
        send("#{assoc}=", Missive::Subscriber.find_or_initialize_by(email:))
        send(assoc).assign_attributes(attributes)
        send(assoc).save!
        send(assoc)
      end
    end

    included do |base|
      base.extend(ClassMethods)
      base.include(InstanceMethods)
      base._define_missive_subscriber_associations
    end
  end
end
