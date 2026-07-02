# == Schema Information
#
# Table name: certification_baby_groots
#
#  id                :bigint           not null, primary key
#  reviewed_at       :datetime
#  status            :integer          default("pending_all_reviews"), not null
#  status_changed_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  project_id        :bigint           not null
#  ship_event_id     :bigint           not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_certification_baby_groots_on_project_id     (project_id)
#  index_certification_baby_groots_on_ship_event_id  (ship_event_id) UNIQUE
#  index_certification_baby_groots_on_status         (status)
#  index_certification_baby_groots_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (ship_event_id => post_ship_events.id)
#  fk_rails_...  (user_id => users.id)
#
module Certification
  class BabyGroot < ApplicationRecord
    belongs_to :project
    belongs_to :ship_event, class_name: "Post::ShipEvent"
    # The author of the project under review.
    belongs_to :user

    has_many :decisions, class_name: "Certification::BabyGrootDecision",
             foreign_key: :baby_groot_id, inverse_of: :baby_groot, dependent: :destroy
    has_one :groot_review, class_name: "Certification::Groot",
            foreign_key: :baby_groot_id, inverse_of: :baby_groot, dependent: :destroy

    has_paper_trail

    enum :status, {
      pending_all_reviews: 0,
      pending_two_reviews: 1,
      pending_one_review: 2,
      sent_to_groot: 3,
      dismissed: 4
    }, default: :pending_all_reviews

    FINAL_STATUSES = %w[sent_to_groot dismissed].freeze

    validates :ship_event_id, uniqueness: true
    validate :reviewed_at_immutable
    validate :reviewed_at_requires_final_status

    before_save :stamp_status_changed_at, if: :will_save_change_to_status?
    before_save :stamp_reviewed_at,
                if: -> { will_save_change_to_status? && FINAL_STATUSES.include?(status) && reviewed_at.nil? }

    def final?
      FINAL_STATUSES.include?(status)
    end

    private

    def stamp_status_changed_at
      self.status_changed_at = Time.current
    end

    def stamp_reviewed_at
      self.reviewed_at = Time.current
    end

    # reviewed_at marks the moment the review left the baby groot queue and is
    # part of the audit trail, so it can never be rewritten afterwards.
    def reviewed_at_immutable
      return unless persisted? && reviewed_at_changed? && reviewed_at_was.present?

      errors.add(:reviewed_at, "cannot be changed once set")
    end

    def reviewed_at_requires_final_status
      return if reviewed_at.blank? || final?

      errors.add(:reviewed_at, "can only be set once the review is sent to groot or dismissed")
    end
  end
end
