require "test_helper"

module Missive
  class ConfigTest < ActionDispatch::IntegrationTest
    test "can define a setting in initializer" do
      # This setting is defined in dummy app initializer
      assert_equal "dummy@example.com", Missive.mailer_from_email
    end

    test "can use a setting default value" do
      # This setting is not defined in dummy app initializer
      assert_equal "Missive", Missive.mailer_from_name
    end
  end
end
