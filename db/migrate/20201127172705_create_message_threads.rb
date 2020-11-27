class CreateMessageThreads < ActiveRecord::Migration[6.0]
  def change
    create_table :message_threads do |t|
      t.string :slug, null: false#, unique: true # apparently this doesn't work here
      # t.datetime :started_at, precision: 6, null: false, index: true

      t.timestamps
    end

    add_index :message_threads, :slug, unique: true
  end
end
