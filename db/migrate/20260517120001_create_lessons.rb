class CreateLessons < ActiveRecord::Migration[8.1]
  def change
    create_table :lessons do |t|
      t.string :name, null: false
      t.integer :day_of_week, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.integer :kind, default: 0, null: false
      t.references :trainer, foreign_key: true

      t.timestamps
    end

    add_index :lessons, [ :day_of_week, :start_time ]
  end
end
