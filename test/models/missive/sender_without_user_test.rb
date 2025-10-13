require "test_helper"

module Missive
  class SenderWithoutUserTest < ActiveSupport::TestCase
    test "works without a ::User class" do
      TempUser = ::User
      Object.send(:remove_const, :User)
      sender = Sender.create!(email: "test@example.com")
      assert sender.persisted?
    ensure
      ::User = TempUser
    end
  end
end
