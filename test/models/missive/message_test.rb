require "test_helper"

module Missive
  class MessageTest < ActiveSupport::TestCase
    test "is invalid without a subject" do
      list = missive_lists(:pristine)
      list.name = nil
      assert_not list.valid?
    end

    test "belongs to a sender" do
      message = missive_messages(:first_newsletter)
      assert message.sender.is_a?(Missive::Sender)
    end

    test "belongs to a list" do
      message = missive_messages(:first_newsletter)
      assert message.list.is_a?(Missive::List)
    end

    test "has many dispatches" do
      message = missive_messages(:first_newsletter)
      assert_equal 2, message.dispatches.count
      assert message.dispatches.first.is_a?(Missive::Dispatch)
    end

    test "has a dispatches counter cache" do
      message = missive_messages(:first_newsletter)
      assert_equal 2, message.dispatches_count
      message.dispatches.create!(sender: message.sender, subscriber: missive_subscribers(:jenny))
      assert_equal 3, message.reload.dispatches_count
      message.dispatches.last.destroy!
      assert_equal 2, message.reload.dispatches_count
    end

    test "is invalid without a list" do
      message = missive_messages(:first_newsletter)
      message.list = nil
      assert_not message.valid?
    end

    test "is invalid without a sender" do
      message = missive_messages(:first_newsletter)
      message.sender = nil
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
