class CreateCertificationGroots < ActiveRecord::Migration[8.1]
  def change
    create_table :certification_groots do |t|
      # One in-depth groot verdict per escalated baby groot review.
      t.references :baby_groot, null: false, index: { unique: true },
                   foreign_key: { to_table: :certification_baby_groots }
      t.references :reviewer, null: false, foreign_key: { to_table: :users }
      t.integer :reviewer_decision
      t.string :reviewer_justification
      t.integer :reviewer_deduction
      t.datetime :reviewed_at

      t.timestamps
    end
  end
end
