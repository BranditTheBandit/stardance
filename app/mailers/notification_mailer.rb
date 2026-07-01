class NotificationMailer < ApplicationMailer
  def notification(notification_id)
    @notification = Notification.find_by(id: notification_id)
    return if @notification.nil?
    return if @notification.recipient.email.blank?

    @recipient = @notification.recipient
    @actor     = @notification.actor
    @record    = @notification.record

    if @notification.loops_transactional_id.present?
      # Loops-native: the body is a JSON transactional payload and Loops owns the
      # design + subject (see loops_transactional.text.erb).
      mail(to: @recipient.email, template_name: "loops_transactional")
    else
      @recommended_items = payout_recommendations
      mail(
        to:            @recipient.email,
        subject:       @notification.email_subject,
        template_name: @notification.template_key
      )
    end
  end

  private

  # Affordable shop-item recommendations for the ship-event payout email, computed
  # once here so the HTML and text parts share one query set. Returns [] for any
  # other notification type or when the flag is off.
  def payout_recommendations
    return [] unless @notification.is_a?(Notifications::Payouts::ShipEventIssued)
    return [] unless Flipper.enabled?(:payout_recommendations, @recipient)

    ShopItem.affordable_for(@recipient, limit: 3)
  end
end
