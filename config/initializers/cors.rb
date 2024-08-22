Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # permitted host
    origins 'http://localhost:3001'

    # permitted access to requests
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end