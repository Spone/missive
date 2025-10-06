module Missive
  module Suppressible
    extend ActiveSupport::Concern

    included do
      time_for_a_boolean :suppressed

      enum :suppression_reason, %i[hard_bounce spam_complaint manual_suppression]

      scope :suppressed, -> { where.not(suppressed_at: nil) }
      scope :not_suppressed, -> { where(suppressed_at: nil) }

      validates :suppression_reason, presence: true, if: :suppressed?

      def suppress!(reason:)
        self.suppression_reason = reason
        suppressed!
        save!
      end

      def unsuppress!
        update!(suppressed_at: nil, suppression_reason: nil)
      end
    end
  end
end
