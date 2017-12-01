Rails.application.routes.draw do
  root to: 'application#status'

  namespace :wordpress do
    post :categories
    post :product
    post :tool
    post :list_categories
    post :select_post
  end
end
