MemoStation::Application.routes.draw do
  resources :articles do
    post :text_post, :on => :collection
  end

  root :to => "articles#index"
end
