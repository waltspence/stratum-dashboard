class CreateAuditFindings < ActiveRecord::Migration[7.2]
  def change
    create_table :audit_findings do |t|
      t.string :target
      t.string :severity
      t.string :status
      t.string :location
      t.text :issue
      t.text :resolution

      t.timestamps
    end
  end
end
