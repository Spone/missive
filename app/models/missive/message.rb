module Missive
  class Message < ApplicationRecord
    belongs_to :list, counter_cache: :messages_count
    has_many :dispatches, dependent: :destroy

    time_for_a_boolean :sent

    validates :subject, presence: true
  end
end
