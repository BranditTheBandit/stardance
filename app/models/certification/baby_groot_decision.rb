module Certification
  class BabyGrootDecision < ApplicationRecord
    # 4-point suspicion slider: 0 (not sus) → 3 (sus).
    DECISION_RANGE = (0..3).freeze

    belongs_to :baby_groot, class_name: "Certification::BabyGroot", inverse_of: :decisions
    belongs_to :reviewer, class_name: "User"

    has_paper_trail

    validates :reviewer_id, uniqueness: { scope: :baby_groot_id }
    validates :reviewer_decision, inclusion: { in: DECISION_RANGE }, allow_nil: true
    validates :reviewer_decision, presence: true, if: -> { reviewed_at.present? }
    validate :immutable_once_reviewed, on: :update

    before_save :stamp_reviewed_at,
                if: -> { will_save_change_to_reviewer_decision? && reviewer_decision.present? && reviewed_at.nil? }
    before_destroy :block_destroy_once_reviewed

    private

    def stamp_reviewed_at
      self.reviewed_at = Time.current
    end

    # A submitted decision is part of the audit trail and can never be edited.
    def immutable_once_reviewed
      return if reviewed_at_in_database.blank? || !changed?

      errors.add(:base, "decision cannot be changed once reviewed")
    end

    def block_destroy_once_reviewed
      return if reviewed_at_in_database.blank?

      errors.add(:base, "decision cannot be deleted once reviewed")
      throw :abort
    end
  end
end
