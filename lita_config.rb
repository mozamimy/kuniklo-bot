Lita.configure do |config|
  config.robot.adapter = :slack
  config.adapters.slack.token = ENV.fetch('SLACK_SECRET_TOKEN')
  config.redis[:url] = ENV['REDIS_URL'] || 'redis://127.0.0.1:6379/0'
end
