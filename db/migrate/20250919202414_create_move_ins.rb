class CreateMoveIns < ActiveRecord::Migration[8.0]
  def change
    create_table :move_ins do |t|
      t.references :user, null: false, foreign_key: true
      # t.jsonb :checklist
      # Checklist: four booleans stored as JSON for flexibility
      t.jsonb :checklist, null: false, default: {
        submit_move_in_inspection_form: false,
        collect_property_keys:         false,
        set_up_utilities:              false, # water, electricity, internet
        review_property_rules:         false
      }
      t.datetime :checklist_completed_at
      t.date :preferred_date
      t.string :preferred_time
      t.integer :status, null: false, default: 0

      t.timestamps
    end
    # Add a GIN index for fast querying inside the checklist JSON
    add_index :move_ins, :checklist, using: :gin
  end
end
