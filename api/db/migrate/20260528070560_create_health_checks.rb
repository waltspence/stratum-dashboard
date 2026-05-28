class CreateHealthChecks < ActiveRecord::Migration[7.2]
  def change
    create_table :health_checks do |t|
      t.string :service
      t.string :status
      t.integer :latency_ms
      t.datetime :checked_at

      t.timestamps
    end
  end
end
