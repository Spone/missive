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

    test "can be suppressed" do
      freeze_time
      subscriber = missive_subscribers(:john)
      assert_nil subscriber.suppressed_at
      assert_not subscriber.suppressed?
      subscriber.suppressed!
      assert_equal Time.zone.now, subscriber.suppressed_at
      assert subscriber.suppressed?
    end
  end
end
