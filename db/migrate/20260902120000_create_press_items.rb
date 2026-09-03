class CreatePressItems < ActiveRecord::Migration[8.1]
  def change
    create_table :press_items do |t|
      t.string :publisher, null: false
      t.integer :publisher_kind, default: 0, null: false
      t.string :headline, null: false
      t.string :url, null: false
      t.string :archive_url
      t.date :published_on, null: false
      t.string :byline
      t.text :quote
      t.boolean :published, default: false, null: false

      t.timestamps
    end

    add_index :press_items, :published_on
    add_index :press_items, :published
    add_index :press_items, :url, unique: true
  end
end
