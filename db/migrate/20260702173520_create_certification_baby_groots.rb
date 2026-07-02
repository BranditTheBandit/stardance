class CreateCertificationBabyGroots < ActiveRecord::Migration[8.1]
  def change
    create_table :certification_baby_groots do |t|
      t.references :project, null: false, foreign_key: true
      # One baby groot review per ship event; a project can accrue several
      # across its ship events.
      t.references :ship_event, null: false, index: { unique: true },
                   foreign_key: { to_table: :post_ship_events }
      t.references :user, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.datetime :status_changed_at
      t.datetime :reviewed_at

      t.timestamps

      t.index :status
    end
  end
end
