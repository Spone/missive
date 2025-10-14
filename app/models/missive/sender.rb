module Missive
  class Sender < ApplicationRecord
    belongs_to :user, class_name: "::User", optional: true
    has_many :dispatches, dependent: :restrict_with_exception
    has_many :lists, dependent: :restrict_with_exception
    has_many :messages, dependent: :restrict_with_exception

    validates :email, presence: true
  end
end
