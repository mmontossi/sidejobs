class CreateSidejobs < ActiveRecord::Migration
  def change
    create_table :sidejobs do |t|
      if ActiveRecord::Base.connection_config[:adapter] == 'postgresql'
        t.jsonb :data
      else
        t.string :data
      end
      t.string :queue
      t.string :status, default: 'pending'
      t.integer :priority, default: 0
      t.integer :attempts, default: 0
      t.text :error
      t.datetime :failed_at
      t.datetime :completed_at
      t.datetime :processed_at
      t.datetime :scheduled_at

      t.timestamps null: false
    end

    add_index :sidejobs, %i(status scheduled_at)
    add_index :sidejobs, :priority
  end
end
