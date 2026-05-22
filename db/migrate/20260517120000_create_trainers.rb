class CreateTrainers < ActiveRecord::Migration[8.1]
  def change
    create_table :trainers do |t|
      t.string :name, null: false
      t.string :title, null: false
      t.text :bio
      t.integer :position, null: false

      t.timestamps
    end

    add_unique_constraint :trainers, :position, deferrable: :deferred
  end
end
