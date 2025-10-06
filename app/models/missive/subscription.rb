module Missive
  class Subscription < ApplicationRecord
    include Suppressible

    belongs_to :subscriber
    belongs_to :list, counter_cache: :subscriptions_count

    validates :list, uniqueness: {scope: :subscriber,
                                  message: "should be subscribed once per subscriber"}
  end
end
