Rails.application.routes.draw do
  root to: 'application#status'

  namespace :wordpress do
    post :categories
    post :product
  end
end
