# frozen_string_literal: true

Rails.application.routes.draw do
  root "dashboard#index"
  scope "/:locale", locale: /#{I18n.available_locales.join("|")}/ do
    devise_for :staffs, controllers: {
      sessions: "sessions"
    }

    resources :students, only: %i[index create destroy]
    resources :standards, only: %i[index create]
    resources :staffs, only: %i[index create]
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  api_version(module: "Api::V1", path: {value: "v1"}, default: true) do
    resources :standards, only: [:index]
    resources :attendances, only: [:create] do
      collection do
        match '/sms_callback' => 'attendances#sms_callback', via: [:get, :post]
        get  :sync
      end
    end
    resources :students, only: [:index]

    namespace :staffs do
      post   "sign_in"  => "sessions#create"
      delete "sign_out" => "sessions#destroy"
      get    "sync"     => "sessions#sync"
    end
  end

  API_VERSIONS.each do |version|
    mount Apitome::Engine => "/api/docs/#{version}",
          :as             => "apitome-#{version}",
          :constraints    => ApitomeVersion.new(version)
  end

  # Optionally default to the last API version
  # mount Apitome::Engine => "/api/docs",
  #       :constraints    => ApitomeVersion.new(API_LAST_VERSION)
end
