class CreateCertificationBabyGrootDecisions < ActiveRecord::Migration[8.1]
  def change
    create_table :certification_baby_groot_decisions do |t|
      t.references :baby_groot, null: false, index: false,
                   foreign_key: { to_table: :certification_baby_groots }
      t.references :reviewer, null: false, foreign_key: { to_table: :users }
      t.integer :reviewer_decision
      t.datetime :reviewed_at

      t.timestamps

      # One decision per reviewer per baby groot review; also covers
      # baby_groot_id lookups in place of a standalone index.
      t.index [ :baby_groot_id, :reviewer_id ], unique: true,
              name: "index_baby_groot_decisions_on_review_and_reviewer"
    end
  end
end
