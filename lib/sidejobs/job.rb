module Sidejobs
  class Job < ActiveRecord::Base

    STATES = %w(pending processing failing complete)

    STATES.each do |name|
      scope name, -> { where(state: name) }
      define_method "#{name}?" do
        state == name
      end
    end

    validates_presence_of :queue, :data, :state
    validates_presence_of :error, if: :failing?
    validates_presence_of :processed_at, if: :processing?
    validates_inclusion_of :state, within: STATES
    validates_numericality_of :priority, :attempts, only_integer: true

    def self.table_name
      'sidejobs'
    end

  end
end
