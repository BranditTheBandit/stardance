module Notifications
  module Payouts
    class ShipEventIssued < ::Notification
      self.default_priority     = :high
      self.aggregatable         = false
      self.slack_template_path  = "notifications/payouts/ship_event_issued"
      self.category_key         = :ship_event_payout_issued
      self.category_label       = "Ship event payouts"
      self.category_description = "Stardust was paid out for one of your ship events"
      self.category_group       = "Stardust"

      def slack_locals
        params.symbolize_keys.slice(:project_title, :ship_date, :hours, :stardust, :multiplier, :blessing)
      end

      def email_subject
        title = params["project_title"]
        title.present? ? "Payout issued for #{title}" : "Ship event payout issued"
      end

      # Send via Loops once its transactional template exists. Inert (nil) until
      # LOOPS_SHIP_EVENT_PAYOUT_TEMPLATE_ID is set, so merging changes nothing
      # until Loops is ready; then this email flips to the Loops JSON payload.
      def loops_transactional_id
        ENV["LOOPS_SHIP_EVENT_PAYOUT_TEMPLATE_ID"].presence
      end

      # Payout details + (behind :payout_recommendations) up to 3 affordable-item
      # recommendations, as flat variables the Loops payout template renders.
      def email_data_variables
        opts     = ActionMailer::Base.default_url_options
        host     = opts[:host] || "stardance.hackclub.com"
        protocol = opts[:protocol] || "https"
        urls     = Rails.application.routes.url_helpers

        vars = {
          stardust:     params["stardust"],
          projectTitle: params["project_title"],
          hours:        params["hours"],
          multiplier:   params["multiplier"],
          shipDate:     params["ship_date"],
          blessing:     params["blessing"],
          balanceUrl:   urls.my_balance_url(host:, protocol:)
        }

        return vars unless Flipper.enabled?(:payout_recommendations, recipient)

        ShopItem.affordable_for(recipient, limit: 3).each_with_index do |item, i|
          n = i + 1
          vars[:"rec#{n}Name"]     = item.name
          vars[:"rec#{n}Price"]    = item.recommended_price
          vars[:"rec#{n}Url"]      = urls.shop_item_url(item, host:, protocol:)
          vars[:"rec#{n}Wishlist"] = item.recommended_from_wishlist?
        end

        vars
      end
    end
  end
end
