Sidejobs.configure do |config|

  config.executions = 3
  config.sleep = 15

  config.queue :default, 1

end
