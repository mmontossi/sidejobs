Sidejobs.configure do |config|

  config.executions = 3
  config.sleep = 15

  config.queue :mailers, 1
  config.queue :newsletters, 1
  config.queue :default, 2

end
