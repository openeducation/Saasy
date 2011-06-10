Rails.application.routes.draw do
  match "sign_in"  => "application#index", :as => "sign_in"
  root :to => "application#index"
end

