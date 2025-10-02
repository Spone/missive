require "test_helper"

module Missive
  class SubscriberWithoutUserTest < ActiveSupport::TestCase
    test "works without a ::User class" do
      TempUser = ::User
      Object.send(:remove_const, :User)
      subscriber = Subscriber.create!(email: "test@example.com")
      assert subscriber.persisted?
    ensure
      ::User = TempUser
    end
  end
end
