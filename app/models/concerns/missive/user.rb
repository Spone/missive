module Missive
  module User
    extend ActiveSupport::Concern

    def self.with(sender: {}, subscriber: {})
      Module.new do
        extend ActiveSupport::Concern

        define_singleton_method(:inspect) { "Missive::User.with(sender: #{sender.inspect}, subscriber: #{subscriber.inspect})" }

        included do
          if sender.empty?
            include Missive::UserAsSender
          else
            include Missive::UserAsSender.with(sender)
          end

          if subscriber.empty?
            include Missive::UserAsSubscriber
          else
            include Missive::UserAsSubscriber.with(subscriber)
          end
        end
      end
    end

    included do
      include Missive::UserAsSender
      include Missive::UserAsSubscriber
    end
  end
end
