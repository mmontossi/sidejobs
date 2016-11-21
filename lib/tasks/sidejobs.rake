namespace :sidejobs do
  desc 'Start daemon.'
  task start: :environment do
    Sidejobs.daemon.start
  end

  desc 'Stop daemon.'
  task stop: :environment do
    Sidejobs.daemon.stop
  end

  desc 'Restart daemon.'
  task restart: :environment do
    Sidejobs.daemon.restart
  end
end
