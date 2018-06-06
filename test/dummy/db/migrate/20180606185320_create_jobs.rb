class CreateJobs < ActiveRecord::Migration[5.1]
  def change
    create_table :jobs do |t|
      t.string :state, default: 'pending'
      t.string :queue, default: 'default'
      t.integer :executions, default: 0
      t.string :activejob_class
      t.string :activejob_id
      t.string :locale
      t.jsonb :arguments, default: {}
      t.text :exception
      t.datetime :scheduled_at
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end

    add_index :jobs, :state
    add_index :jobs, :queue
    add_index :jobs, :activejob_class
    add_index :jobs, :activejob_id
    add_index :jobs, :locale
    add_index :jobs, :scheduled_at
    add_index :jobs, :created_at
  end
end
