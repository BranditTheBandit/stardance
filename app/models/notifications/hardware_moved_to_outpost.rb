module Notifications
  # Heads-up that hardware projects live on Hack Club Outpost now, surfaced when
  # a hardware project records a Lookout timelapse (replaces the old on-recorder
  # popup). Inbox-only (low priority — no Slack/email), and aggregatable so a
  # builder who records repeatedly keeps a single unread notice rather than a
  # pile of them.
  class HardwareMovedToOutpost < ::Notification
    self.default_priority     = :low
    self.aggregatable         = true
    self.category_key         = :hardware_moved_to_outpost
    self.category_label       = "Hardware moved to Outpost"
    self.category_description = "Hardware projects have moved to Hack Club Outpost"
    self.category_group       = "General"

    def preview_text
      "Building hardware? It all happens over on Hack Club Outpost now."
    end
  end
end
