require "test_helper"

module Missive
  class SubscriptionTest < ActiveSupport::TestCase
    test "must be unique for subscriber and list" do
      assert_raises(ActiveRecord::RecordInvalid) do
        Subscription.create!(subscriber: missive_subscribers(:john), list: missive_lists(:newsletter))
      end
    end
  end
end
