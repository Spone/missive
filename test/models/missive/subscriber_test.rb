require "test_helper"

module Missive
  class SubscriberTest < ActiveSupport::TestCase
    test "belongs to a user" do
      email = "test@example.com"
      user = ::User.create!(email:)
      subscriber = Subscriber.create!(email:, user:)
      assert_equal user, subscriber.user
      assert_equal user.subscriber, subscriber
    end

    test "has many dispatches" do
      subscriber = missive_subscribers(:john)
      assert_equal 1, subscriber.dispatches.count
      assert subscriber.dispatches.first.is_a?(Missive::Dispatch)
    end

    test "has many subscriptions" do
      subscriber = missive_subscribers(:john)
      assert_equal 1, subscriber.subscriptions.count
      assert subscriber.subscriptions.first.is_a?(Missive::Subscription)
    end

    test "has many lists" do
      subscriber = missive_subscribers(:john)
      assert_equal 1, subscriber.lists.count
      assert subscriber.lists.first.is_a?(Missive::List)
    end
  end
end
