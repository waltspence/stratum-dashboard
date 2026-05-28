class CreateAgents < ActiveRecord::Migration[7.2]
  def change
    create_table :agents do |t|
      t.string :name
      t.string :model
      t.string :provider
      t.string :status
      t.string :task
      t.datetime :last_seen

      t.timestamps
    end
  end
end
