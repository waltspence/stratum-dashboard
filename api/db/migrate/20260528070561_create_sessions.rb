class CreateSessions < ActiveRecord::Migration[7.2]
  def change
    create_table :sessions do |t|
      t.string :agent
      t.string :model
      t.integer :tokens_in
      t.integer :tokens_out
      t.integer :duration_ms

      t.timestamps
    end
  end
end
