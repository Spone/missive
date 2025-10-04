class CreateMissiveLists < ActiveRecord::Migration[8.0]
  def change
    create_table :missive_lists do |t|
      t.string :name, null: false
      t.integer :subscriptions_count, default: 0
      t.integer :messages_count, default: 0
      t.timestamp :last_message_sent_at
      t.string :postmark_message_stream_id

      t.timestamps
    end
  end
end
