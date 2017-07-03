module Sidejobs
  class Queue

    def add(data, options={})
      Job.create(
        data: data,
        queue: (options[:queue] || 'default'),
        priority: (options[:priority] || 0),
        scheduled_at: options[:schedule_at]
      )
    end

    def fetch
      Job.where(status: %w(pending failing)).where(
        'attempts < ?',
        Sidejobs.configuration.max_attempts
      ).where(
        'scheduled_at <= ? OR scheduled_at IS NULL',
        Time.now
      ).order(priority: :desc).limit(Sidejobs.configuration.batch_size)
    end

  end
end
