# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # origins 'http://localhost:3000'
    origins "*"  # 👈 Change '*' to specific domains in production for security (e.g., 'example.com')

    resource "*",
      headers: :any,
      expose: [ "Authorization" ],  # 👈 Expose Authorization header for JWT
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ]
  end
end
