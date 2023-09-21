resources :job_listings, only: [:index] do
    collection do
      get 'search'
    end
  end
  