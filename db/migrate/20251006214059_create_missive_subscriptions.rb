class CreateMissiveSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :missive_subscriptions do |t|
      t.references :subscriber, null: false, foreign_key: {to_table: "missive_subscribers"}
      t.references :list, null: false, foreign_key: {to_table: "missive_lists"}
      t.timestamp :suppressed_at
      t.integer :suppression_reason

      t.index [:subscriber_id, :list_id], unique: true

      t.timestamps
    end
  end
end
