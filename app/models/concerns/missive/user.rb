module Missive
  module User
    extend ActiveSupport::Concern

    included do
      include Missive::UserAsSender
      include Missive::UserAsSubscriber
    end
  end
end
