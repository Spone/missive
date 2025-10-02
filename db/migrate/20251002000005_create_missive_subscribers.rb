class CreateMissiveSubscribers < ActiveRecord::Migration[8.0]
  def change
    create_table :missive_subscribers do |t|
      t.string :email, null: false
      t.timestamp :suppressed_at
      t.integer :suppression_reason
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
