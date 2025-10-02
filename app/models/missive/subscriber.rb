module Missive
  class Subscriber < ApplicationRecord
    time_for_a_boolean :suppressed

    enum :suppression_reason, [:hard_bounce, :spam_complaint, :manual_suppression]
  end
end
