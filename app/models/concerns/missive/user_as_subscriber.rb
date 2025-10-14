module Missive
  module UserAsSubscriber
    extend ActiveSupport::Concern

    included do
      has_one :subscriber, class_name: "Missive::Subscriber", dependent: :destroy
      has_many :dispatches, class_name: "Missive::Dispatch", through: :subscriber
      has_many :subscribed_lists, class_name: "Missive::List", through: :subscriber
      has_many :subscriptions, class_name: "Missive::Subscription", through: :subscriber

      def init_subscriber(attributes = {})
        self.subscriber = Missive::Subscriber.find_or_initialize_by(email:)
        subscriber.assign_attributes(attributes)
        subscriber.save!
      end
    end
  end
end
