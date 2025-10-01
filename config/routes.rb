Missive::Engine.routes.draw do
  namespace :postmark do
    post "webhooks", to: "webhooks#receive"
  end
end
