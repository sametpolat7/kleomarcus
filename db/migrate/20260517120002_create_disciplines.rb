class CreateDisciplines < ActiveRecord::Migration[8.1]
  def change
    create_table :disciplines do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :disciplines, :name, unique: true
  end
end
