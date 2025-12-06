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

# Flush Redis in development mode if requested
if Rails.env.development? && ENV["DISCOURSE_FLUSH_REDIS"]
  puts "Flushing redis (development mode)"
  Discourse.redis.flushdb
end

# Verify Redis version
begin
  if Gem::Version.new(Discourse.redis.info["redis_version"]) < Gem::Version.new("6.2.0")
    STDERR.puts "Discourse requires Redis 6.2.0 or up"
    exit 1
  end
rescue Redis::CannotConnectError
  STDERR.puts "Couldn't connect to Redis at #{ENV["REDIS_URL"]}"
end