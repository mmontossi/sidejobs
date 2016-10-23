namespace :sidejobs do
  task start: :environment do
    Sidejobs.daemon.start
  end
  task stop: :environment do
    Sidejobs.daemon.stop
  end
  task restart: :environment do
    Sidejobs.daemon.restart
  end
end
