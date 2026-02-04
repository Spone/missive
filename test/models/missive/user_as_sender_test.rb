require "test_helper"

module Missive
  class UserAsSenderTest < ActiveSupport::TestCase
    test "has no missive_sender by default" do
      user = ::User.new
      assert_nil user.missive_sender
    end

    test "can have a missive_sender" do
      user = ::User.create!(email: "jessica@example.com")
      sender = Missive::Sender.new(email: user.email)
      user.update!(missive_sender: sender)
      assert_equal sender, user.missive_sender
    end

    test "can create a sender with #init_sender" do
      user = ::User.create!(email: "jessica@example.com")
      sender = user.init_sender
      assert sender.persisted?
      assert user.missive_sender.persisted?
      assert_equal user.email, user.missive_sender.email
    end

    test "can associate an existing sender with #init_sender" do
      sender = missive_senders(:david)
      user = ::User.create!(email: sender.email)
      sender = user.init_sender
      assert sender.persisted?
      assert user.missive_sender.persisted?
      assert_equal user.email, user.missive_sender.email
    end

    test "can create a sender with #init_sender and give them a name" do
      user = ::User.create!(email: "jessica@example.com")
      user.init_sender(name: "Jessica")
      assert user.missive_sender.persisted?
      assert_equal user.email, user.missive_sender.email
      assert_equal "Jessica", user.missive_sender.name
    end

    test "can associate an existing sender with #init_sender and give them a name" do
      sender = missive_senders(:david)
      user = ::User.create!(email: sender.email)
      user.init_sender(name: "Dave")
      assert user.missive_sender.persisted?
      assert_equal user.email, user.missive_sender.email
      assert_equal "Dave", user.missive_sender.name
    end

    test "can create a sender with #init_sender and give them a reply to email" do
      user = ::User.create!(email: "jessica@example.com")
      user.init_sender(reply_to_email: "contact@example.com")
      assert user.missive_sender.persisted?
      assert_equal user.email, user.missive_sender.email
      assert_equal "contact@example.com", user.missive_sender.reply_to_email
    end

    test "can associate an existing sender with #init_sender and give them a reply to email" do
      sender = missive_senders(:david)
      user = ::User.create!(email: sender.email)
      user.init_sender(reply_to_email: "contact@example.com")
      assert user.missive_sender.persisted?
      assert_equal user.email, user.missive_sender.email
      assert_equal "contact@example.com", user.missive_sender.reply_to_email
    end

    test "has no missive_sent_dispatches by default" do
      user = ::User.new
      assert_empty user.missive_sent_dispatches
    end

    test "can have missive_sent_dispatches" do
      user = ::User.create!(email: "jessica@example.com")
      sender = user.init_sender
      dispatch = missive_dispatches(:john_first_newsletter)
      sender.dispatches << dispatch
      assert_equal [dispatch], user.missive_sent_dispatches
    end

    test "has no missive_sent_lists by default" do
      user = ::User.new
      assert_empty user.missive_sent_lists
    end

    test "can have missive_sent_lists" do
      user = ::User.create!(email: "jessica@example.com")
      sender = user.init_sender
      list = missive_lists(:newsletter)
      sender.lists << list
      assert_equal [list], user.missive_sent_lists
    end

    test "has no missive_sent_messages by default" do
      user = ::User.new
      assert_empty user.missive_sent_messages
    end

    test "can have missive_sent_messages" do
      user = ::User.create!(email: "jessica@example.com")
      sender = user.init_sender
      message = missive_messages(:first_newsletter)
      sender.messages << message
      assert_equal [message], user.missive_sent_messages
    end
  end

  class UserAsSenderConfigurationTest < ActiveSupport::TestCase
    class UserWithCustomSender < ApplicationRecord
      self.table_name = "users"
      include Missive::UserAsSender.with(
        sender: :sender,
        sent_dispatches: :sent_dispatches,
        sent_lists: :sent_lists,
        sent_messages: :sent_messages
      )
    end

    test "responds to custom association names" do
      user = UserWithCustomSender.new
      assert user.respond_to?(:sender)
      assert user.respond_to?(:sent_dispatches)
      assert user.respond_to?(:sent_lists)
      assert user.respond_to?(:sent_messages)
    end

    test "does not define default associations when using custom names" do
      user = UserWithCustomSender.new
      refute user.respond_to?(:missive_sender)
      refute user.respond_to?(:missive_sent_dispatches)
      refute user.respond_to?(:missive_sent_lists)
      refute user.respond_to?(:missive_sent_messages)
    end

    test "stores custom configuration" do
      assert_equal :sender, UserWithCustomSender.missive_sender_config[:sender]
      assert_equal :sent_dispatches, UserWithCustomSender.missive_sender_config[:sent_dispatches]
    end

    test "init_sender works with custom association name" do
      user = UserWithCustomSender.create!(email: "custom@example.com")
      sender = user.init_sender
      assert sender.persisted?
      assert_equal user.email, user.sender.email
    end

    test "init_sender with attributes works with custom association name" do
      user = UserWithCustomSender.create!(email: "custom@example.com")
      user.init_sender(name: "Custom Name")
      assert_equal "Custom Name", user.sender.name
    end

    test "through associations work with custom names" do
      user = UserWithCustomSender.create!(email: "custom@example.com")
      user.init_sender
      list = missive_lists(:newsletter)
      user.sender.lists << list
      assert_equal [list], user.sent_lists
    end

    test "raises error when association already exists" do
      error = assert_raises(Missive::UserAsSender::AssociationAlreadyDefinedError) do
        Class.new(ApplicationRecord) do
          self.table_name = "users"
          has_one :missive_sender
          include Missive::UserAsSender
        end
      end

      assert_match(/Association :missive_sender is already defined/, error.message)
      assert_match(/Missive::UserAsSender\.with/, error.message)
    end
  end
end
