class AddArrivesAtToMessage < ActiveRecord::Migration[6.0]
  def change
    add_column :messages, :arrives_at, :datetime, precision: 6, null: false
    add_index :messages, :arrives_at
  end
end
