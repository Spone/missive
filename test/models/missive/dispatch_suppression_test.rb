require "test_helper"

module Missive
  class DispatchSuppressionTest < ActiveSupport::TestCase
    test "dispatch is not suppressed by default" do
      assert_not Dispatch.new.suppressed?
    end

    test "dispatch responds to suppression reason predicates" do
      assert_not Dispatch.new.hard_bounce?
      assert_not Dispatch.new.spam_complaint?
      assert_not Dispatch.new.manual_suppression?
    end

    test "dispatch has no suppression reason" do
      assert_nil Dispatch.new.suppression_reason
    end

    test "dispatch can hard bounce" do
      dispatch = missive_dispatches(:john_first_newsletter)
      dispatch.suppressed_at = Time.zone.now
      dispatch.hard_bounce!
      assert dispatch.suppressed?
      assert dispatch.hard_bounce?
    end

    test "dispatch can complain about spam" do
      dispatch = missive_dispatches(:john_first_newsletter)
      dispatch.suppressed_at = Time.zone.now
      dispatch.spam_complaint!
      assert dispatch.suppressed?
      assert dispatch.spam_complaint?
    end

    test "dispatch can be manually suppressed" do
      dispatch = missive_dispatches(:john_first_newsletter)
      dispatch.suppressed_at = Time.zone.now
      dispatch.manual_suppression!
      assert dispatch.suppressed?
      assert dispatch.manual_suppression?
    end

    test "#suppressed!" do
      freeze_time
      dispatch = missive_dispatches(:john_first_newsletter)
      assert_nil dispatch.suppressed_at
      assert_not dispatch.suppressed?
      dispatch.suppressed!
      assert_equal Time.zone.now, dispatch.suppressed_at
      assert dispatch.suppressed?
    end

    test "is invalid if suppressed without a reason" do
      dispatch = missive_dispatches(:john_first_newsletter)
      dispatch.suppressed!
      assert_not dispatch.valid?
      assert_equal ["can't be blank"], dispatch.errors[:suppression_reason]
    end
  end
end
