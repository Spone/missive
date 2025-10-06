module Missive
  class List < ApplicationRecord
    has_many :messages, dependent: :destroy
    has_many :subscriptions, dependent: :destroy
    has_many :subscribers, through: :subscriptions

    validates :name, presence: true
  end
end
