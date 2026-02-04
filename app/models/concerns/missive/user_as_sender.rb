module Missive
  module UserAsSender
    extend ActiveSupport::Concern

    class AssociationAlreadyDefinedError < StandardError; end

    DEFAULT_ASSOCIATION_NAMES = {
      sender: :missive_sender,
      sent_dispatches: :missive_sent_dispatches,
      sent_lists: :missive_sent_lists,
      sent_messages: :missive_sent_messages
    }.freeze

    def self.with(options = {})
      config = DEFAULT_ASSOCIATION_NAMES.merge(options)

      Module.new do
        extend ActiveSupport::Concern

        define_singleton_method(:inspect) { "Missive::UserAsSender.with(#{options.inspect})" }

        included do |base|
          base.instance_variable_set(:@missive_sender_config, config)
          base.extend(ClassMethods)
          base.include(InstanceMethods)
          base._define_missive_sender_associations
        end
      end
    end

    module ClassMethods
      def missive_sender_config
        @missive_sender_config ||= DEFAULT_ASSOCIATION_NAMES.dup
      end

      def _define_missive_sender_associations
        config = missive_sender_config

        _check_missive_association_collision!(config[:sender])

        has_one config[:sender], class_name: "Missive::Sender", foreign_key: :user_id, dependent: :nullify
        has_many config[:sent_dispatches], class_name: "Missive::Dispatch", through: config[:sender], source: :dispatches
        has_many config[:sent_lists], class_name: "Missive::List", through: config[:sender], source: :lists
        has_many config[:sent_messages], class_name: "Missive::Message", through: config[:sender], source: :messages
      end

      def _check_missive_association_collision!(name)
        return unless reflect_on_association(name)

        raise AssociationAlreadyDefinedError,
          "Association :#{name} is already defined on #{self.name}. " \
          "Use Missive::UserAsSender.with to specify a different name. " \
          "Example: include Missive::UserAsSender.with(sender: :missive_sender)"
      end
    end

    module InstanceMethods
      def init_sender(attributes = {})
        assoc = self.class.missive_sender_config[:sender]
        send("#{assoc}=", Missive::Sender.find_or_initialize_by(email:))
        send(assoc).assign_attributes(attributes)
        send(assoc).save!
        send(assoc)
      end
    end

    included do |base|
      base.extend(ClassMethods)
      base.include(InstanceMethods)
      base._define_missive_sender_associations
    end
  end
end
