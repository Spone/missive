require "test_helper"

module Missive
  class SubscriberSuppressionTest < ActiveSupport::TestCase
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

    test ".suppressed scope" do
      assert_not_includes Subscriber.suppressed, missive_subscribers(:john)
      assert_includes Subscriber.suppressed, missive_subscribers(:jane)
    end

    test ".not_suppressed scope" do
      assert_includes Subscriber.not_suppressed, missive_subscribers(:john)
      assert_not_includes Subscriber.not_suppressed, missive_subscribers(:jane)
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

    test "#suppressed!" do
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

    test "#suppress!" do
      freeze_time
      subscriber = missive_subscribers(:john)
      assert_nil subscriber.suppressed_at
      assert_not subscriber.suppressed?
      subscriber.suppress!(reason: :hard_bounce)
      assert_equal Time.zone.now, subscriber.suppressed_at
      assert subscriber.suppressed?
      assert subscriber.hard_bounce?
    end
  end
end
