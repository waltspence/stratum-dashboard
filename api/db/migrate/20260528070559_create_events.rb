class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      t.string :event_type
      t.string :source
      t.json :payload

      t.timestamps
    end
  end
end
