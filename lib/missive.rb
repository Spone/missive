require "missive/version"
require "missive/engine"

module Missive
  # Configuration
  mattr_accessor :mailer_from_email, default: "noreply@example.com"
  mattr_accessor :mailer_from_name, default: "Missive"
end
