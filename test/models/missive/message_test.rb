require "test_helper"

module Missive
  class MessageTest < ActiveSupport::TestCase
    test "is invalid without a subject" do
      list = missive_lists(:pristine)
      list.name = nil
      assert_not list.valid?
    end

    test "belongs to a list" do
      message = missive_messages(:first_newsletter)
      assert message.list.is_a?(Missive::List)
    end

    test "is invalid without a list" do
      message = missive_messages(:first_newsletter)
      message.list = nil
      assert_not message.valid?
    end
  end
end
