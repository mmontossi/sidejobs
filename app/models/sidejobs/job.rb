module Sidejobs
  class Job < ActiveRecord::Base

    self.table_name = 'jobs'

    STATES = %w(pending executing failing complete failed)

    MAPPINGS = { 'activejob_class' => 'job_class', 'activejob_id' => 'job_id', 'queue' => 'queue_name', 'arguments' => 'arguments', 'executions' => 'executions', 'locale' => 'locale' }

    scope :succeeding, -> { where.not state: %w(failing failed) }
    scope :started, -> { where.not state: 'pending' }
    scope :finished, -> { where state: %w(complete failed) }

    validates_presence_of :state
    validates_presence_of :exception, unless: :succeeding?
    validates_presence_of :started_at, if: :started?
    validates_numericality_of :executions, only_integer: true, greater_than_or_equal_to: 0

    with_options if: :finished? do
      validates_presence_of :finished_at
      validates_time_of :finished_at, after: :started_at
    end

    constraint :state, STATES

    def started?
      state != 'pending'
    end

    def finished?
      %w(complete failed).include? state
    end

    def succeeding?
      %w(failing failed).exclude? state
    end

    def duration
      if finished_at && started_at
        (finished_at - started_at).round
      end
    end

    def execute
      self.started_at = Time.now
      self.state = 'executing'
      self.executions += 1
      save!
      begin
        # Try single line with inject
        hash = {}
        MAPPINGS.each do |name, activejob_name|
          hash[activejob_name] = send(name)
        end
        ActiveJob::Base.execute hash
        self.state = 'complete'
      rescue => exception
        self.exception = exception.message
        if executions < Sidejobs.configuration.executions
          self.state = 'failing'
          self.scheduled_at = (Time.now + (executions * 10))
        else
          self.state = 'failed'
        end
      end
      self.finished_at = Time.now
      save!
    end

    class << self

      def execute(queue)
        # Select updating fundamental
        where(queue: queue, state: %w(pending failing)).where(
          'executions < ?',
          Sidejobs.configuration.executions
        ).where(
          'scheduled_at <= ? OR scheduled_at IS NULL',
          Time.now
        ).order(created_at: :asc).first.try :execute
      end

      def enqueue(job, timestamp=nil)
        hash = job.serialize.slice(*MAPPINGS.values)
        MAPPINGS.each do |name, activejob_name|
          unless hash.has_key?(name)
            hash[name] = hash.delete(activejob_name)
          end
        end
        queue = hash['queue'].to_sym
        if Sidejobs.configuration.queues.exclude?(queue)
          hash['queue'] = 'default'
        end
        if timestamp
          hash['scheduled_at'] = Time.at(timestamp)
        end
        instance = Job.new(hash)
        instance.save!
        instance
      end

    end
  end
end
