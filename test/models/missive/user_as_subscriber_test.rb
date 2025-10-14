require "test_helper"

module Missive
  class UserAsSubscriberTest < ActiveSupport::TestCase
    test "has no subscriber by default" do
      user = ::User.new
      assert_nil user.subscriber
    end

    test "has no dispatches by default" do
      user = ::User.new
      assert_empty user.dispatches
    end

    test "has no subscribed_lists by default" do
      user = ::User.new
      assert_empty user.subscribed_lists
    end

    test "has no subscriptions by default" do
      user = ::User.new
      assert_empty user.subscriptions
    end

    test "can have a subscriber" do
      user = ::User.create!(email: "jessica@example.com")
      subscriber = Missive::Subscriber.new(email: user.email)
      user.update!(subscriber:)
      assert_equal subscriber, user.subscriber
    end

    test "can create a subscriber with #init_subscriber" do
      user = ::User.create!(email: "jessica@example.com")
      user.init_subscriber
      assert user.subscriber.persisted?
      assert_equal user.email, user.subscriber.email
    end

    test "can associate an existing subscriber with #init_subscriber" do
      subscriber = missive_subscribers(:jenny)
      user = ::User.create!(email: subscriber.email)
      user.init_subscriber
      assert user.subscriber.persisted?
      assert_equal user.email, user.subscriber.email
    end
  end
end
