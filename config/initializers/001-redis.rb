# frozen_string_literal: true

# Force Discourse to use the REDIS_URL environment variable
Discourse.redis = Redis.new(url: ENV["REDIS_URL"])

# Ensure Sidekiq also uses the same Redis connection
if defined?(Sidekiq)
  Sidekiq.configure_server do |config|
    config.redis = { url: ENV["REDIS_URL"] }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: ENV["REDIS_URL"] }
  end
end

