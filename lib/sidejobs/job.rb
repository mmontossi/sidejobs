module Sidejobs
  class Job < ActiveRecord::Base

    STATUS = %w(pending processing failing complete)

    STATUS.each do |name|
      scope name, -> { where(status: name) }
      define_method "#{name}?" do
        status == name
      end
    end

    validates_presence_of :queue, :data, :status
    validates_presence_of :error, :failed_at, if: :failing?
    validates_presence_of :completed_at, if: :complete?
    validates_presence_of :processed_at, if: :processing?
    validates_inclusion_of :status, within: STATUS
    validates_numericality_of :priority, :attempts, only_integer: true

    def self.table_name
      'sidejobs'
    end

  end
end
