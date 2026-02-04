module Missive
  module UserAsSender
    extend ActiveSupport::Concern

    class AssociationAlreadyDefinedError < StandardError; end

    ASSOCIATION_NAMES = %i[sender sent_dispatches sent_lists sent_messages].freeze

    class_methods do
      def missive_sender_config
        @missive_sender_config ||= ASSOCIATION_NAMES.index_with { |name| name }
      end

      def configure_missive_sender(options = {})
        missive_sender_config.merge!(options)
        _define_missive_sender_associations
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
          "Use configure_missive_sender to specify a different name. " \
          "Example: configure_missive_sender(sender: :missive_sender)"
      end
    end

    included do
      _define_missive_sender_associations

      def init_sender(attributes = {})
        assoc = self.class.missive_sender_config[:sender]
        send("#{assoc}=", Missive::Sender.find_or_initialize_by(email:))
        send(assoc).assign_attributes(attributes)
        send(assoc).save!
        send(assoc)
      end
    end
  end
end
