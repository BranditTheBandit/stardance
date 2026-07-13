class AddGithubEmailToRaffleParticipants < ActiveRecord::Migration[8.0]
  def change
    add_column :raffle_participants, :github_email, :string
  end
end
