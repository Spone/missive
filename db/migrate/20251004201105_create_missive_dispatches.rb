class CreateMissiveDispatches < ActiveRecord::Migration[8.0]
  def change
    create_table :missive_dispatches do |t|
      t.references :subscriber, null: false, foreign_key: {to_table: :missive_subscribers}
      t.references :message, null: false, foreign_key: {to_table: :missive_messages}
      t.string :postmark_message_stream_id
      t.string :postmark_message_id
      t.timestamp :sent_at
      t.timestamp :delivered_at
      t.timestamp :opened_at
      t.timestamp :clicked_at
      t.timestamp :suppressed_at
      t.integer :suppression_reason

      t.timestamps
    end
  end
end
