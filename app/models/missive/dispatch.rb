module Missive
  class Dispatch < ApplicationRecord
    include Suppressible

    belongs_to :sender
    belongs_to :subscriber
    belongs_to :message, counter_cache: :dispatches_count
    has_one :list, through: :message
    has_one :subscription, ->(dispatch) { where(list: dispatch.list) }, through: :subscriber, source: :subscriptions

    time_for_a_boolean :sent
    time_for_a_boolean :delivered
    time_for_a_boolean :opened
    time_for_a_boolean :clicked

    validates :message, uniqueness: {scope: :subscriber,
                                     message: "should be dispatched once per subscriber"}
  end
end
