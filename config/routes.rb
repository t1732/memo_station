Rails.application.routes.draw do
  resources :articles do
    post :text_post, :on => :collection
  end

  root "articles#index"
end
