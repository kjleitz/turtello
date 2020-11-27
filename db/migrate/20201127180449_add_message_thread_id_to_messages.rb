class AddMessageThreadIdToMessages < ActiveRecord::Migration[6.0]
  def change
    add_reference :messages, :message_thread, null: false, foreign_key: true
  end
end
