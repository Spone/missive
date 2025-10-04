require "test_helper"

module Missive
  class ListTest < ActiveSupport::TestCase
    test "is invalid without a name" do
      list = missive_lists(:pristine)
      list.name = nil
      assert_not list.valid?
    end

    test "has many messages" do
      list = missive_lists(:newsletter)
      assert_equal 2, list.messages.count
      assert list.messages.first.is_a?(Missive::Message)
    end
  end
end
