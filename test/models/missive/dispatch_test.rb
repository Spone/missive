require "test_helper"

module Missive
  class DispatchTest < ActiveSupport::TestCase
    test "must be unique for subscriber and message" do
      assert_raises(ActiveRecord::RecordInvalid) do
        Dispatch.create!(subscriber: missive_subscribers(:john), message: missive_messages(:first_newsletter))
      end
    end

    test "can be sent" do
      freeze_time
      dispatch = missive_dispatches(:john_first_newsletter)
      assert_nil dispatch.sent_at
      assert_not dispatch.sent?
      dispatch.sent!
      assert_equal Time.zone.now, dispatch.sent_at
      assert dispatch.sent?
    end

    test "can be opened" do
      freeze_time
      dispatch = missive_dispatches(:john_first_newsletter)
      assert_nil dispatch.opened_at
      assert_not dispatch.opened?
      dispatch.opened!
      assert_equal Time.zone.now, dispatch.opened_at
      assert dispatch.opened?
    end

    test "can be clicked" do
      freeze_time
      dispatch = missive_dispatches(:john_first_newsletter)
      assert_nil dispatch.clicked_at
      assert_not dispatch.clicked?
      dispatch.clicked!
      assert_equal Time.zone.now, dispatch.clicked_at
      assert dispatch.clicked?
    end

    test "can be suppressed" do
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
