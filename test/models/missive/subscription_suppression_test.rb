require "test_helper"

module Missive
  class SubscriptionSuppressionTest < ActiveSupport::TestCase
    test "subscription is not suppressed by default" do
      assert_not Subscription.new.suppressed?
    end

    test "subscription responds to suppression reason predicates" do
      assert_not Subscription.new.hard_bounce?
      assert_not Subscription.new.spam_complaint?
      assert_not Subscription.new.manual_suppression?
    end

    test "subscription has no suppression reason" do
      assert_nil Subscription.new.suppression_reason
    end

    test "subscription can hard bounce" do
      subscription = missive_subscriptions(:john_newsletter)
      subscription.suppressed_at = Time.zone.now
      subscription.hard_bounce!
      assert subscription.suppressed?
      assert subscription.hard_bounce?
    end

    test "subscription can complain about spam" do
      subscription = missive_subscriptions(:john_newsletter)
      subscription.suppressed_at = Time.zone.now
      subscription.spam_complaint!
      assert subscription.suppressed?
      assert subscription.spam_complaint?
    end

    test "subscription can be manually suppressed" do
      subscription = missive_subscriptions(:john_newsletter)
      subscription.suppressed_at = Time.zone.now
      subscription.manual_suppression!
      assert subscription.suppressed?
      assert subscription.manual_suppression?
    end

    test "#suppressed!" do
      freeze_time
      subscription = missive_subscriptions(:john_newsletter)
      assert_nil subscription.suppressed_at
      assert_not subscription.suppressed?
      subscription.suppressed!
      assert_equal Time.zone.now, subscription.suppressed_at
      assert subscription.suppressed?
    end

    test "is invalid if suppressed without a reason" do
      subscription = missive_subscriptions(:john_newsletter)
      subscription.suppressed!
      assert_not subscription.valid?
      assert_equal ["can't be blank"], subscription.errors[:suppression_reason]
    end
  end
end
