module Missive
  module UserAsSender
    extend ActiveSupport::Concern

    included do
      has_one :sender, class_name: "Missive::Sender", dependent: :nullify
      has_many :sent_dispatches, class_name: "Missive::Dispatch", through: :sender, source: :dispatches
      has_many :sent_lists, class_name: "Missive::List", through: :sender, source: :lists
      has_many :sent_messages, class_name: "Missive::Message", through: :sender, source: :messages

      def init_sender(attributes = {})
        self.sender = Missive::Sender.find_or_initialize_by(email:)
        sender.assign_attributes(attributes)
        sender.save!
        sender
      end
    end
  end
end
