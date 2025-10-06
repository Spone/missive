require "test_helper"

module Missive
  class ListTest < ActiveSupport::TestCase
    test "is invalid without a name" do
      list = missive_lists(:pristine)
      list.name = nil
      assert_not list.valid?
    end

    test "has many messages" do
      list = missive_lists(:newsletter)
      assert_equal 2, list.messages.count
      assert list.messages.first.is_a?(Missive::Message)
    end

    test "has a messages counter cache" do
      list = missive_lists(:newsletter)
      assert_equal 2, list.messages_count
      list.messages.create!(subject: "Hello, world!")
      assert_equal 3, list.reload.messages_count
      list.messages.last.destroy!
      assert_equal 2, list.reload.messages_count
    end

    test "has many subscriptions" do
      list = missive_lists(:newsletter)
      assert_equal 1, list.subscriptions.count
      assert list.subscriptions.first.is_a?(Missive::Subscription)
    end

    test "has many subscribers" do
      list = missive_lists(:newsletter)
      assert_equal 1, list.subscribers.count
      assert list.subscribers.first.is_a?(Missive::Subscriber)
    end

    test "has a subscriptions counter cache" do
      list = missive_lists(:newsletter)
      assert_equal 1, list.subscriptions_count
      list.subscriptions.create!(subscriber: missive_subscribers(:jane))
      assert_equal 2, list.reload.subscriptions_count
      list.subscriptions.last.destroy!
      assert_equal 1, list.reload.subscriptions_count
      list.subscribers << missive_subscribers(:jane)
      assert_equal 2, list.reload.subscriptions_count
    end
  end
end
