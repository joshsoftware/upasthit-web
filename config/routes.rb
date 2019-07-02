Rails.application.routes.draw do

  root "dashboard#index"
  scope "/:locale", locale: /#{I18n.available_locales.join("|")}/ do

    devise_for :staffs, controllers: {
      sessions: 'sessions'
    }

    resources :students, only: [:index, :create, :destroy]
    resources :standards, only: [:index, :create]
    resources :staffs, only: [:index, :create]
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api, defaults: { format: :json } do
    resources :standards, only: [:index]
    resources :attendances, only: [:create] do
      collection do
        post :sms_callback
      end
    end
    resources :students, only: [:index]

    namespace :staffs do
      post   'sign_in'  => 'sessions#create'
      delete 'sign_out' => 'sessions#destroy'
    end
  end
end
