class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.belongs_to :sender, null: false
      t.belongs_to :receiver, null: false
      t.text :body

      t.timestamps
    end
  end
end
