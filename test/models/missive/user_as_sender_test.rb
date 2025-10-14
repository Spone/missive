require "test_helper"

module Missive
  class UserTest < ActiveSupport::TestCase
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

    test "can init a sender" do
      user = ::User.create!(email: "jessica@example.com")
      user.init_sender
      assert user.sender.persisted?
      assert_equal user.email, user.sender.email
    end

    test "can init a sender with a name" do
      user = ::User.create!(email: "jessica@example.com")
      user.init_sender(name: "Jessica")
      assert user.sender.persisted?
      assert_equal user.email, user.sender.email
      assert_equal "Jessica", user.sender.name
    end

    test "can init a sender with a reply to email" do
      user = ::User.create!(email: "jessica@example.com")
      user.init_sender(reply_to_email: "contact@example.com")
      assert user.sender.persisted?
      assert_equal user.email, user.sender.email
      assert_equal "contact@example.com", user.sender.reply_to_email
    end
  end
end
