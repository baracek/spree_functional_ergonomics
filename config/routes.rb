Rails.application.routes.draw do
  namespace :admin do 
    resources :orders do
      member do
        get :add_product
        get :do_checkout
      end
    end
  end
end
