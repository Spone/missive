require "test_helper"

module Missive
  class UserAsSenderTest < ActiveSupport::TestCase
    test "has no sender by default" do
      user = ::User.new
      assert_nil user.sender
    end

    test "can have a sender" do
      user = ::User.create!(email: "jessica@example.com")
      sender = Missive::Sender.new(email: user.email)
      user.update!(sender:)
      assert_equal sender, user.sender
    end

    test "can create a sender with #init_sender" do
      user = ::User.create!(email: "jessica@example.com")
      sender = user.init_sender
      assert sender.persisted?
      assert user.sender.persisted?
      assert_equal user.email, user.sender.email
    end

    test "can associate an existing sender with #init_sender" do
      sender = missive_senders(:david)
      user = ::User.create!(email: sender.email)
      sender = user.init_sender
      assert sender.persisted?
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

    test "has no sent_dispatches by default" do
      user = ::User.new
      assert_empty user.sent_dispatches
    end

    test "can have sent_dispatches" do
      user = ::User.create!(email: "jessica@example.com")
      sender = user.init_sender
      dispatch = missive_dispatches(:john_first_newsletter)
      sender.dispatches << dispatch
      assert_equal [dispatch], user.sent_dispatches
    end

    test "has no sent_lists by default" do
      user = ::User.new
      assert_empty user.sent_lists
    end

    test "can have sent_lists" do
      user = ::User.create!(email: "jessica@example.com")
      sender = user.init_sender
      list = missive_lists(:newsletter)
      sender.lists << list
      assert_equal [list], user.sent_lists
    end

    test "has no sent_messages by default" do
      user = ::User.new
      assert_empty user.sent_messages
    end

    test "can have sent_messages" do
      user = ::User.create!(email: "jessica@example.com")
      sender = user.init_sender
      message = missive_messages(:first_newsletter)
      sender.messages << message
      assert_equal [message], user.sent_messages
    end
  end

  class UserAsSenderConfigurationTest < ActiveSupport::TestCase
    class UserWithCustomSender < ApplicationRecord
      self.table_name = "users"
      include Missive::UserAsSender

      configure_missive_sender(
        sender: :missive_sender,
        sent_dispatches: :missive_sent_dispatches,
        sent_lists: :missive_sent_lists,
        sent_messages: :missive_sent_messages
      )
    end

    test "responds to custom association names" do
      user = UserWithCustomSender.new
      assert user.respond_to?(:missive_sender)
      assert user.respond_to?(:missive_sent_dispatches)
      assert user.respond_to?(:missive_sent_lists)
      assert user.respond_to?(:missive_sent_messages)
    end

    test "stores custom configuration" do
      assert_equal :missive_sender, UserWithCustomSender.missive_sender_config[:sender]
      assert_equal :missive_sent_dispatches, UserWithCustomSender.missive_sender_config[:sent_dispatches]
    end

    test "init_sender works with custom association name" do
      user = UserWithCustomSender.create!(email: "custom@example.com")
      sender = user.init_sender
      assert sender.persisted?
      assert_equal user.email, user.missive_sender.email
    end

    test "init_sender with attributes works with custom association name" do
      user = UserWithCustomSender.create!(email: "custom@example.com")
      user.init_sender(name: "Custom Name")
      assert_equal "Custom Name", user.missive_sender.name
    end

    test "through associations work with custom names" do
      user = UserWithCustomSender.create!(email: "custom@example.com")
      user.init_sender
      list = missive_lists(:newsletter)
      user.missive_sender.lists << list
      assert_equal [list], user.missive_sent_lists
    end

    test "raises error when sender association already exists" do
      error = assert_raises(Missive::UserAsSender::AssociationAlreadyDefinedError) do
        Class.new(ApplicationRecord) do
          self.table_name = "users"
          has_one :sender
          include Missive::UserAsSender
        end
      end

      assert_match(/Association :sender is already defined/, error.message)
      assert_match(/configure_missive_sender/, error.message)
    end
  end
end
