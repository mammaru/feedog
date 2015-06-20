class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.integer :feed_id
      t.text :summary
      t.string :title
      t.string :url
      t.datetime :published_at

      t.timestamps null: false
    end
  end
end
