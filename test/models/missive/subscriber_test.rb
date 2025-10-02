require "test_helper"

module Missive
  class SubscriberTest < ActiveSupport::TestCase
    test "subscriber is not suppressed by default" do
      assert_not Subscriber.new.suppressed?
    end

    test "subscriber responds to suppression reason predicates" do
      assert_not Subscriber.new.hard_bounce?
      assert_not Subscriber.new.spam_complaint?
      assert_not Subscriber.new.manual_suppression?
    end

    test "subscriber has no suppression reason" do
      assert_nil Subscriber.new.suppression_reason
    end

    test "subscriber can hard bounce" do
      subscriber = missive_subscribers(:john)
      subscriber.suppressed_at = Time.zone.now
      subscriber.hard_bounce!
      assert subscriber.suppressed?
      assert subscriber.hard_bounce?
    end

    test "subscriber can complain about spam" do
      subscriber = missive_subscribers(:john)
      subscriber.suppressed_at = Time.zone.now
      subscriber.spam_complaint!
      assert subscriber.suppressed?
      assert subscriber.spam_complaint?
    end

    test "subscriber can be manually suppressed" do
      subscriber = missive_subscribers(:john)
      subscriber.suppressed_at = Time.zone.now
      subscriber.manual_suppression!
      assert subscriber.suppressed?
      assert subscriber.manual_suppression?
    end
  end
end
