module Missive
  class Dispatch < ApplicationRecord
    include Suppressible

    belongs_to :subscriber
    belongs_to :message, counter_cache: :dispatches_count

    time_for_a_boolean :sent
    time_for_a_boolean :delivered
    time_for_a_boolean :opened
    time_for_a_boolean :clicked

    validates :message, uniqueness: {scope: :subscriber,
                                     message: "should be dispatched once per subscriber"}
  end
end
