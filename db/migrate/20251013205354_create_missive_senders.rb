class CreateMissiveSenders < ActiveRecord::Migration[8.0]
  def change
    create_table :missive_senders do |t|
      t.string :email, null: false
      t.string :name
      t.string :reply_to_email
      t.integer :postmark_sender_signature_id
      t.references :user, foreign_key: false

      t.timestamps
    end

    add_reference :missive_dispatches, :sender, null: false, foreign_key: {to_table: "missive_senders"}
    add_reference :missive_lists, :sender, null: false, foreign_key: {to_table: "missive_senders"}
    add_reference :missive_messages, :sender, null: false, foreign_key: {to_table: "missive_senders"}
  end
end
