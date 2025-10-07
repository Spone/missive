module Missive
  class ApplicationMailer < ActionMailer::Base
    default from: email_address_with_name(Missive.mailer_from_email, Missive.mailer_from_name)

    layout "mailer"
  end
end
