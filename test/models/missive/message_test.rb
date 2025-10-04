require "test_helper"

module Missive
  class MessageTest < ActiveSupport::TestCase
    test "is invalid without a subject" do
      list = missive_lists(:pristine)
      list.name = nil
      assert_not list.valid?
    end

    test "belongs to a list" do
      message = missive_messages(:first_newsletter)
      assert message.list.is_a?(Missive::List)
    end

    test "is invalid without a list" do
      message = missive_messages(:first_newsletter)
      message.list = nil
      assert_not message.valid?
    end

    test "can be sent" do
      freeze_time
      message = missive_messages(:second_newsletter)
      assert_nil message.sent_at
      assert_not message.sent?
      message.sent!
      assert_equal Time.zone.now, message.sent_at
      assert message.sent?
    end
  end
end
