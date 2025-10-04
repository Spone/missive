require "test_helper"

module Missive
  class ListTest < ActiveSupport::TestCase
    test "is invalid without a name" do
      list = missive_lists(:pristine)
      list.name = nil
      assert_not list.valid?
    end
  end
end
