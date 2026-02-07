require "missive/version"
require "missive/engine"
require "postmark"
require "missive/stamp/api_client"

module Missive
  # Configuration
  mattr_accessor :mailer_from_email, default: "noreply@example.com"
  mattr_accessor :mailer_from_name, default: "Missive"
end
