require "test_helper"

module Missive
  class UserAsSubscriberTest < ActiveSupport::TestCase
    test "has no subscriber by default" do
      user = ::User.new
      assert_nil user.subscriber
    end

    test "can have a subscriber" do
      user = ::User.create!(email: "jessica@example.com")
      subscriber = Missive::Subscriber.new(email: user.email)
      user.update!(subscriber:)
      assert_equal subscriber, user.subscriber
    end

    test "can create a subscriber with #init_subscriber" do
      user = ::User.create!(email: "jessica@example.com")
      subscriber = user.init_subscriber
      assert subscriber.persisted?
      assert user.subscriber.persisted?
      assert_equal user.email, user.subscriber.email
    end

    test "can associate an existing subscriber with #init_subscriber" do
      subscriber = missive_subscribers(:jenny)
      user = ::User.create!(email: subscriber.email)
      subscriber = user.init_subscriber
      assert subscriber.persisted?
      assert user.subscriber.persisted?
      assert_equal user.email, user.subscriber.email
    end

    test "has no dispatches by default" do
      user = ::User.new
      assert_empty user.dispatches
    end

    test "can have dispatches" do
      user = ::User.create!(email: "jessica@example.com")
      subscriber = user.init_subscriber
      dispatch = missive_dispatches(:john_first_newsletter)
      subscriber.dispatches << dispatch
      assert_equal [dispatch], user.dispatches
    end

    test "has no subscriptions by default" do
      user = ::User.new
      assert_empty user.subscriptions
    end

    test "can have subscriptions" do
      user = ::User.create!(email: "jessica@example.com")
      subscriber = user.init_subscriber
      subscription = missive_subscriptions(:john_newsletter)
      subscriber.subscriptions << subscription
      assert_equal [subscription], user.subscriptions
    end

    test "has no subscribed_lists by default" do
      user = ::User.new
      assert_empty user.subscribed_lists
    end

    test "can have subscribed_lists" do
      user = ::User.create!(email: "jessica@example.com")
      user.init_subscriber
      list = missive_lists(:newsletter)
      user.subscriber.subscriptions.create!(list:)
      assert_equal [list], user.subscribed_lists
    end

    test "has no unsubscribed_lists by default" do
      user = ::User.new
      assert_empty user.unsubscribed_lists
    end

    test "can have unsubscribed_lists" do
      user = ::User.create!(email: "jessica@example.com")
      user.init_subscriber
      list = missive_lists(:newsletter)
      user.subscriber.subscriptions.create!(list:)
      user.subscriptions.find_by(list:).suppress!(reason: :manual_suppression)
      assert_equal [list], user.unsubscribed_lists
    end
  end

  class UserAsSubscriberConfigurationTest < ActiveSupport::TestCase
    class UserWithCustomSubscriber < ApplicationRecord
      self.table_name = "users"
      include Missive::UserAsSubscriber

      configure_missive_subscriber(
        subscriber: :missive_subscriber,
        dispatches: :missive_dispatches,
        subscriptions: :missive_subscriptions,
        subscribed_lists: :missive_subscribed_lists,
        unsubscribed_lists: :missive_unsubscribed_lists
      )
    end

    test "responds to custom association names" do
      user = UserWithCustomSubscriber.new
      assert user.respond_to?(:missive_subscriber)
      assert user.respond_to?(:missive_dispatches)
      assert user.respond_to?(:missive_subscriptions)
      assert user.respond_to?(:missive_subscribed_lists)
      assert user.respond_to?(:missive_unsubscribed_lists)
    end

    test "stores custom configuration" do
      assert_equal :missive_subscriber, UserWithCustomSubscriber.missive_subscriber_config[:subscriber]
      assert_equal :missive_dispatches, UserWithCustomSubscriber.missive_subscriber_config[:dispatches]
    end

    test "init_subscriber works with custom association name" do
      user = UserWithCustomSubscriber.create!(email: "custom@example.com")
      subscriber = user.init_subscriber
      assert subscriber.persisted?
      assert_equal user.email, user.missive_subscriber.email
    end

    test "through associations work with custom names" do
      user = UserWithCustomSubscriber.create!(email: "custom@example.com")
      user.init_subscriber
      list = missive_lists(:newsletter)
      user.missive_subscriber.subscriptions.create!(list:)
      assert_equal [list], user.missive_subscribed_lists
    end

    test "raises error when subscriber association already exists" do
      error = assert_raises(Missive::UserAsSubscriber::AssociationAlreadyDefinedError) do
        Class.new(ApplicationRecord) do
          self.table_name = "users"
          has_one :subscriber
          include Missive::UserAsSubscriber
        end
      end

      assert_match(/Association :subscriber is already defined/, error.message)
      assert_match(/configure_missive_subscriber/, error.message)
    end
  end
end
