class User < ApplicationRecord
  has_one :sender, class_name: "Missive::Sender", dependent: :nullify
  has_one :subscriber, class_name: "Missive::Subscriber", dependent: :destroy
end
