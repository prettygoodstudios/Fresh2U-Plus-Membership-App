Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :charges
  get "/check_membership", to: "charges#check_membership"
  get "/renew_membership", to: "charges#renew_membership"
  post "/update_membership", to: "charges#update_membership"
end
