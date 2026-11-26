class CreateFeedbacks < ActiveRecord::Migration[8.1]
  def change
    create_table :feedbacks do |t|
      t.integer :topic, null: false
      t.text :message, null: false

      t.timestamps
    end

    add_index :feedbacks, :topic
    add_index :feedbacks, :created_at
  end
end
