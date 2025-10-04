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

    test "has a messages counter cache" do
      list = missive_lists(:newsletter)
      assert_equal 2, list.messages_count
      list.messages.create!(subject: "Hello, world!")
      assert_equal 3, list.messages_count
      list.messages.last.destroy!
      assert_equal 2, list.messages_count
    end
  end
end
