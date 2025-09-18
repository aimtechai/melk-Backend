class CreateMaintenanceRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :maintenance_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.string :location
      t.integer :status, null: false, default: 0
      t.boolean :allow_entry, null: false, default: false
      t.bigint :assigned_to_user_id
      t.string :request_code

      t.timestamps
    end

    add_foreign_key :maintenance_requests, :users, column: :assigned_to_user_id
    add_index :maintenance_requests, :request_code, unique: true
    add_index :maintenance_requests, :status
  end
end
