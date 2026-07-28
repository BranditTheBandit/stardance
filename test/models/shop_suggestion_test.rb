require "test_helper"

class ShopSuggestionTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    LedgerEntry.create!(user: @user, ledgerable: @user, amount: 1_000_000, reason: "Test balance top-up")
  end

  test "usd_cost must fit within the decimal(8,2) column" do
    suggestion = build_suggestion(usd_cost: 999_999.99)
    assert suggestion.valid?, suggestion.errors.full_messages.to_sentence

    suggestion = build_suggestion(usd_cost: 1_000_000)
    assert_not suggestion.valid?
    assert_includes suggestion.errors[:usd_cost], "must be less than 1000000"
  end

  test "saving a suggestion with an out-of-range usd_cost does not raise" do
    suggestion = build_suggestion(usd_cost: 1_000_000)
    assert_not suggestion.save
  end

  private

  def build_suggestion(usd_cost:)
    @user.shop_suggestions.build(
      name: "Silly suggestion",
      description: "A suggestion with a silly cost",
      usd_cost: usd_cost,
      image: png_upload
    )
  end

  # A real 1x1 PNG so ActiveStorage's spoofing protection accepts it.
  def png_upload
    data = Base64.decode64(
      "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=="
    )
    file = Tempfile.new([ "suggestion", ".png" ])
    file.binmode
    file.write(data)
    file.rewind
    Rack::Test::UploadedFile.new(file.path, "image/png")
  end
end
