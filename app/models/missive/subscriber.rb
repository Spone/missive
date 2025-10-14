module Missive
  class Subscriber < ApplicationRecord
    include Suppressible

    belongs_to :user, class_name: "::User", optional: true
    has_many :dispatches, dependent: :destroy
    has_many :subscriptions, dependent: :destroy
    has_many :lists, through: :subscriptions

    validates :email, presence: true
  end
end
