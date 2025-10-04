module Missive
  class Message < ApplicationRecord
    belongs_to :list, counter_cache: :messages_count

    time_for_a_boolean :sent

    validates :subject, presence: true
  end
end
