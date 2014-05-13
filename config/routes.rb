Gms::Engine.routes.draw do
  resources :accounts #, :defaults => { :format => :json }, only: [:index, :show, :create, :update, :destroy]
end
