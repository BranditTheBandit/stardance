# frozen_string_literal: true

# Public, shareable "I earned this" page for a single shop purchase. The URL is
# keyed by ShopOrder#signed_id (purpose: :artifact), not the sequential id, so
# purchases can't be enumerated. The page is open to anyone with the link; the
# link is only mintable from the buyer's own orders page (behind :artifact_share).
class ArtifactsController < ApplicationController
  def show
    @order = ShopOrder.find_signed(params[:id], purpose: :artifact)
    if @order.nil?
      skip_authorization
      return head :not_found
    end

    authorize @order, :show?, policy_class: ArtifactPolicy

    @item             = @order.shop_item
    @buyer            = @order.user
    @stardust_spent   = @order.total_cost_with_modifiers
    @featured_project = featured_project_for(@buyer)
  end

  private

  # Stardust is a pooled balance, so a purchase isn't tied to a specific ship.
  # Feature the buyer's most recent ship-event payout's project as the thing
  # they "earned it by shipping". Best-effort: nil falls back to generic copy.
  def featured_project_for(user)
    LedgerEntry
      .where(user: user, ledgerable_type: "Post::ShipEvent")
      .order(created_at: :desc)
      .first&.ledgerable&.post&.project
  rescue StandardError
    nil
  end
end
