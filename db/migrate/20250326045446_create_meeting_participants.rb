class CreateMeetingParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :meeting_participants do |t|
      t.references :user, null: false, foreign_key: true
      t.references :booking, null: false, foreign_key: true
      t.string :status, default: 'pending', null: false

      t.timestamps
    end
  end
end
