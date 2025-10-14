require "test_helper"

module Missive
  class UserAsSenderTest < ActiveSupport::TestCase
    test "has no sender by default" do
      user = ::User.new
      assert_nil user.sender
    end

    test "has no sent_dispatches by default" do
      user = ::User.new
      assert_empty user.sent_dispatches
    end

    test "has no sent_lists by default" do
      user = ::User.new
      assert_empty user.sent_lists
    end

    test "has no sent_messages by default" do
      user = ::User.new
      assert_empty user.sent_messages
    end

    test "can have a sender" do
      user = ::User.create!(email: "jessica@example.com")
      sender = Missive::Sender.new(email: user.email)
      user.update!(sender:)
      assert_equal sender, user.sender
    end

    test "can create a sender with #init_sender" do
      user = ::User.create!(email: "jessica@example.com")
      user.init_sender
      assert user.sender.persisted?
      assert_equal user.email, user.sender.email
    end

    test "can associate an existing sender with #init_sender" do
      sender = missive_senders(:david)
      user = ::User.create!(email: sender.email)
      user.init_sender
      assert user.sender.persisted?
      assert_equal user.email, user.sender.email
    end

    test "can create a sender with #init_sender and give them a name" do
      user = ::User.create!(email: "jessica@example.com")
      user.init_sender(name: "Jessica")
      assert user.sender.persisted?
      assert_equal user.email, user.sender.email
      assert_equal "Jessica", user.sender.name
    end

    test "can associate an existing sender with #init_sender and give them a name" do
      sender = missive_senders(:david)
      user = ::User.create!(email: sender.email)
      user.init_sender(name: "Dave")
      assert user.sender.persisted?
      assert_equal user.email, user.sender.email
      assert_equal "Dave", user.sender.name
    end

    test "can create a sender with #init_sender and give them a reply to email" do
      user = ::User.create!(email: "jessica@example.com")
      user.init_sender(reply_to_email: "contact@example.com")
      assert user.sender.persisted?
      assert_equal user.email, user.sender.email
      assert_equal "contact@example.com", user.sender.reply_to_email
    end

    test "can associate an existing sender with #init_sender and give them a reply to email" do
      sender = missive_senders(:david)
      user = ::User.create!(email: sender.email)
      user.init_sender(reply_to_email: "contact@example.com")
      assert user.sender.persisted?
      assert_equal user.email, user.sender.email
      assert_equal "contact@example.com", user.sender.reply_to_email
    end
  end
end
