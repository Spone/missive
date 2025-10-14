require "test_helper"

module Missive
  class SenderTest < ActiveSupport::TestCase
    test "belongs to a user" do
      email = "test@example.com"
      user = ::User.create!(email:)
      sender = Sender.create!(email:, user:)
      assert_equal user, sender.user
      assert_equal user.sender, sender
    end

    test "has many dispatches" do
      sender = missive_senders(:david)
      assert_equal 2, sender.dispatches.count
      assert sender.dispatches.first.is_a?(Missive::Dispatch)
    end

    test "has many messages" do
      sender = missive_senders(:david)
      assert_equal 2, sender.messages.count
      assert sender.messages.first.is_a?(Missive::Message)
    end

    test "has many lists" do
      sender = missive_senders(:david)
      assert_equal 2, sender.lists.count
      assert sender.lists.first.is_a?(Missive::List)
    end

    test "cannot destroy a sender that has dispatches" do
      sender = missive_senders(:pristine)
      sender.dispatches << missive_dispatches(:john_first_newsletter)
      assert_raises ActiveRecord::DeleteRestrictionError do
        sender.destroy!
      end
    end

    test "cannot destroy a sender that has messages" do
      sender = missive_senders(:pristine)
      sender.messages << missive_messages(:first_newsletter)
      assert_raises ActiveRecord::DeleteRestrictionError do
        sender.destroy!
      end
    end

    test "cannot destroy a sender that has lists" do
      sender = missive_senders(:pristine)
      sender.lists << missive_lists(:newsletter)
      assert_raises ActiveRecord::DeleteRestrictionError do
        sender.destroy!
      end
    end
  end
end
