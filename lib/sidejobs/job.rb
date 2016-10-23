module Sidejobs
  class Job < ActiveRecord::Base
    self.table_name = 'sidejobs'

    validates_presence_of :queue, :data, :status
    validates_presence_of :error, :failed_at, if: -> { status == 'failing' }
    validates_presence_of :completed_at, if: -> { status == 'complete' }
    validates_presence_of :processed_at, if: -> { status == 'processsing' }
    validates_inclusion_of :status, within: %w(pending processing failing complete)
    validates_numericality_of :priority, :attempts, only_integer: true

  end
end
