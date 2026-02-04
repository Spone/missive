require "test_helper"

module Missive
  class UserAsSubscriberTest < ActiveSupport::TestCase
    test "has no missive_subscriber by default" do
      user = ::User.new
      assert_nil user.missive_subscriber
    end

    test "can have a missive_subscriber" do
      user = ::User.create!(email: "jessica@example.com")
      subscriber = Missive::Subscriber.new(email: user.email)
      user.update!(missive_subscriber: subscriber)
      assert_equal subscriber, user.missive_subscriber
    end

    test "can create a subscriber with #init_subscriber" do
      user = ::User.create!(email: "jessica@example.com")
      subscriber = user.init_subscriber
      assert subscriber.persisted?
      assert user.missive_subscriber.persisted?
      assert_equal user.email, user.missive_subscriber.email
    end

    test "can associate an existing subscriber with #init_subscriber" do
      subscriber = missive_subscribers(:jenny)
      user = ::User.create!(email: subscriber.email)
      subscriber = user.init_subscriber
      assert subscriber.persisted?
      assert user.missive_subscriber.persisted?
      assert_equal user.email, user.missive_subscriber.email
    end

    test "has no missive_dispatches by default" do
      user = ::User.new
      assert_empty user.missive_dispatches
    end

    test "can have missive_dispatches" do
      user = ::User.create!(email: "jessica@example.com")
      subscriber = user.init_subscriber
      dispatch = missive_dispatches(:john_first_newsletter)
      subscriber.dispatches << dispatch
      assert_equal [dispatch], user.missive_dispatches
    end

    test "has no missive_subscriptions by default" do
      user = ::User.new
      assert_empty user.missive_subscriptions
    end

    test "can have missive_subscriptions" do
      user = ::User.create!(email: "jessica@example.com")
      subscriber = user.init_subscriber
      subscription = missive_subscriptions(:john_newsletter)
      subscriber.subscriptions << subscription
      assert_equal [subscription], user.missive_subscriptions
    end

    test "has no missive_subscribed_lists by default" do
      user = ::User.new
      assert_empty user.missive_subscribed_lists
    end

    test "can have missive_subscribed_lists" do
      user = ::User.create!(email: "jessica@example.com")
      user.init_subscriber
      list = missive_lists(:newsletter)
      user.missive_subscriber.subscriptions.create!(list:)
      assert_equal [list], user.missive_subscribed_lists
    end

    test "has no missive_unsubscribed_lists by default" do
      user = ::User.new
      assert_empty user.missive_unsubscribed_lists
    end

    test "can have missive_unsubscribed_lists" do
      user = ::User.create!(email: "jessica@example.com")
      user.init_subscriber
      list = missive_lists(:newsletter)
      user.missive_subscriber.subscriptions.create!(list:)
      user.missive_subscriptions.find_by(list:).suppress!(reason: :manual_suppression)
      assert_equal [list], user.missive_unsubscribed_lists
    end
  end

  class UserAsSubscriberConfigurationTest < ActiveSupport::TestCase
    class UserWithCustomSubscriber < ApplicationRecord
      self.table_name = "users"
      include Missive::UserAsSubscriber.with(
        subscriber: :subscriber,
        dispatches: :dispatches,
        subscriptions: :subscriptions,
        subscribed_lists: :subscribed_lists,
        unsubscribed_lists: :unsubscribed_lists
      )
    end

    test "responds to custom association names" do
      user = UserWithCustomSubscriber.new
      assert user.respond_to?(:subscriber)
      assert user.respond_to?(:dispatches)
      assert user.respond_to?(:subscriptions)
      assert user.respond_to?(:subscribed_lists)
      assert user.respond_to?(:unsubscribed_lists)
    end

    test "does not define default associations when using custom names" do
      user = UserWithCustomSubscriber.new
      refute user.respond_to?(:missive_subscriber)
      refute user.respond_to?(:missive_dispatches)
      refute user.respond_to?(:missive_subscriptions)
      refute user.respond_to?(:missive_subscribed_lists)
      refute user.respond_to?(:missive_unsubscribed_lists)
    end

    test "stores custom configuration" do
      assert_equal :subscriber, UserWithCustomSubscriber.missive_subscriber_config[:subscriber]
      assert_equal :dispatches, UserWithCustomSubscriber.missive_subscriber_config[:dispatches]
    end

    test "init_subscriber works with custom association name" do
      user = UserWithCustomSubscriber.create!(email: "custom@example.com")
      subscriber = user.init_subscriber
      assert subscriber.persisted?
      assert_equal user.email, user.subscriber.email
    end

    test "through associations work with custom names" do
      user = UserWithCustomSubscriber.create!(email: "custom@example.com")
      user.init_subscriber
      list = missive_lists(:newsletter)
      user.subscriber.subscriptions.create!(list:)
      assert_equal [list], user.subscribed_lists
    end

    test "raises error when association already exists" do
      error = assert_raises(Missive::UserAsSubscriber::AssociationAlreadyDefinedError) do
        Class.new(ApplicationRecord) do
          self.table_name = "users"
          has_one :subscriber
          include Missive::UserAsSubscriber.with(subscriber: :subscriber)
        end
      end

      assert_match(/Association :subscriber is already defined/, error.message)
      assert_match(/Missive::UserAsSubscriber\.with/, error.message)
    end
  end
end
