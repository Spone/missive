require "test_helper"

module Missive
  class UserTest < ActiveSupport::TestCase
    test "has no subscriber by default" do
      user = ::User.new
      assert_nil user.subscriber
    end

    test "can have a subscriber" do
      user = ::User.create!(email: "jessica@example.com")
      subscriber = Missive::Subscriber.new(email: user.email)
      user.update!(subscriber:)
      assert_equal subscriber, user.subscriber
    end

    test "can init a subscriber" do
      user = ::User.create!(email: "jessica@example.com")
      user.init_subscriber
      assert user.subscriber.persisted?
      assert_equal user.email, user.subscriber.email
    end
  end
end
