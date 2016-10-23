module Sidejobs
  class Railtie < Rails::Railtie

    initializer :sidejobs do
      ::ActiveJob::QueueAdapters.include(
        Sidejobs::Extensions::ActiveJob::QueueAdapters
      )
    end

    rake_tasks do
      load 'tasks/sidejobs.rake'
    end

  end
end
