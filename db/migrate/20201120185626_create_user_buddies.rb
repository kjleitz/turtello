class CreateUserBuddies < ActiveRecord::Migration[6.0]
  def change
    create_table :user_buddies do |t|
      t.belongs_to :user, null: false
      t.belongs_to :buddy, null: false

      t.timestamps
    end

    add_index :user_buddies, [:user_id, :buddy_id], unique: true
  end
end
