class CreateMissiveMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :missive_messages do |t|
      t.string :subject, null: false
      t.integer :dispatches_count, default: 0
      t.references :list, null: false, foreign_key: {to_table: "missive_lists"}
      t.string :postmark_message_stream_id
      t.timestamp :sent_at

      t.timestamps
    end
  end
end
