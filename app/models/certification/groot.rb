# == Schema Information
#
# Table name: certification_groots
#
#  id                     :bigint           not null, primary key
#  reviewed_at            :datetime
#  reviewer_decision      :integer
#  reviewer_deduction     :integer
#  reviewer_justification :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  baby_groot_id          :bigint           not null
#  reviewer_id            :bigint           not null
#
# Indexes
#
#  index_certification_groots_on_baby_groot_id  (baby_groot_id) UNIQUE
#  index_certification_groots_on_reviewer_id    (reviewer_id)
#
# Foreign Keys
#
#  fk_rails_...  (baby_groot_id => certification_baby_groots.id)
#  fk_rails_...  (reviewer_id => users.id)
#
module Certification
  class Groot < ApplicationRecord
    belongs_to :baby_groot, class_name: "Certification::BabyGroot", inverse_of: :groot_review
    belongs_to :reviewer, class_name: "User"

    has_paper_trail

    enum :reviewer_decision, {
      not_fraudulent: 0,
      banned: 1,
      deduction: 2
    }

    validates :baby_groot_id, uniqueness: true
    validates :reviewer_decision, presence: true, if: -> { reviewed_at.present? }
    validates :reviewer_justification, presence: true, if: -> { banned? || deduction? }
    # Minutes of fraudulent time deducted from the project; only meaningful
    # for a deduction verdict.
    validates :reviewer_deduction, presence: true,
              numericality: { only_integer: true, greater_than: 0 }, if: :deduction?
    validates :reviewer_deduction, absence: true, unless: :deduction?

    before_save :stamp_reviewed_at,
                if: -> { will_save_change_to_reviewer_decision? && reviewer_decision.present? && reviewed_at.nil? }

    private

    def stamp_reviewed_at
      self.reviewed_at = Time.current
    end
  end
end
