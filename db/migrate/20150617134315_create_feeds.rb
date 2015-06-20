class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.integer :category_id
      t.string :title
      t.string :url
      t.string :feed_url
      t.datetime :last_modified

      t.timestamps null: false
    end
  end
end
