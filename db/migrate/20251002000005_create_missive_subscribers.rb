class CreateMissiveSubscribers < ActiveRecord::Migration[8.0]
  def change
    create_table :missive_subscribers do |t|
      t.string :email
      t.timestamp :suppressed_at
      t.integer :suppression_reason

      t.timestamps
    end
  end
end
