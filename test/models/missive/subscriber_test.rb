require "test_helper"

module Missive
  class SubscriberTest < ActiveSupport::TestCase
    test "belongs to a user" do
      email = "test@example.com"
      user = User.create!(email:)
      subscriber = Subscriber.create!(email:, user:)
      assert_equal user, subscriber.user
      assert_equal user.subscriber, subscriber
    end

    test "has many dispatches" do
      subscriber = missive_subscribers(:john)
      assert_equal 1, subscriber.dispatches.count
      assert subscriber.dispatches.first.is_a?(Missive::Dispatch)
    end

    test "can be suppressed" do
      freeze_time
      subscriber = missive_subscribers(:john)
      assert_nil subscriber.suppressed_at
      assert_not subscriber.suppressed?
      subscriber.suppressed!
      assert_equal Time.zone.now, subscriber.suppressed_at
      assert subscriber.suppressed?
    end

    test "is invalid if suppressed without a reason" do
      subscriber = missive_subscribers(:john)
      subscriber.suppressed!
      assert_not subscriber.valid?
      assert_equal ["can't be blank"], subscriber.errors[:suppression_reason]
    end
  end
end
