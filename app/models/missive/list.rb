module Missive
  class List < ApplicationRecord
    has_many :messages, dependent: :destroy, counter_cache: :messages_count
    # has_many :subscriptions, dependent: :destroy, counter_cache: true
    # has_many :subscriber, through: :subscriptions

    validates :name, presence: true
  end
end
