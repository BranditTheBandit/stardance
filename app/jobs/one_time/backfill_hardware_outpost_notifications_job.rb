# frozen_string_literal: true

# One-off sweep to drop the "hardware moved to Outpost" notice into the inbox of
# everyone who already owns a hardware project — not just those who go on to
# record a timelapse (LookoutSessionsController#create fires the same notice for
# that path). New hardware projects can't be created on Stardance anymore
# (creation is redirected to Outpost), so this audience is a fixed set; run once
# when the feature is live.
#
# HardwareMovedToOutpost is aggregatable, so a user who already has an unread
# copy (e.g. from recording) just gets it bumped, not duplicated. notify() also
# self-gates on the notification system's own rollout flag (week_2_release), so
# users without it are skipped.
#
# DRY RUN BY DEFAULT: logs how many users it would notify and writes nothing.
# Pass dry_run: false to actually create the notifications.
class OneTime::BackfillHardwareOutpostNotificationsJob < ApplicationJob
  queue_as :literally_whenever

  def perform(dry_run: true)
    user_ids = Project::Membership
                 .where(project_id: Project.where.not(hardware_stage: nil).select(:id))
                 .distinct
                 .pluck(:user_id)

    Rails.logger.info("[BackfillHardwareOutpost] #{user_ids.size} hardware-project users (dry_run: #{dry_run})")
    return if dry_run

    notified = 0
    User.where(id: user_ids).find_each do |user|
      notified += 1 if Notifications::HardwareMovedToOutpost.notify(recipient: user)
    end
    Rails.logger.info("[BackfillHardwareOutpost] notified #{notified} of #{user_ids.size} users")
  end
end
