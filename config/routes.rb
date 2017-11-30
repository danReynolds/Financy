Rails.application.routes.draw do
  root to: 'application#status'

  namespace :wordpress do
    post :categories
  end
end
