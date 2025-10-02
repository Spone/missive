class User < ApplicationRecord
  has_one :subscriber, class_name: "Missive::Subscriber", dependent: :destroy
end
