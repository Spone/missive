module Missive
  class Subscriber < ApplicationRecord
    belongs_to :user, optional: true
    # has_many :subscriptions, dependent: :destroy
    # has_many :lists, through: :subscriptions

    time_for_a_boolean :suppressed

    enum :suppression_reason, [:hard_bounce, :spam_complaint, :manual_suppression]

    validates :email, presence: true
  end
end
