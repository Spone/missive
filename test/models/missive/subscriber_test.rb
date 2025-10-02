require "test_helper"

module Missive
  class SubscriberTest < ActiveSupport::TestCase
    test "belongs to a user" do
      email = "test@example.com"
      user = User.create!(email:)
      subscriber = Subscriber.create!(email:, user:)
      assert_equal user, subscriber.user
      assert_equal user.subscriber, subscriber
    end
  end
end
