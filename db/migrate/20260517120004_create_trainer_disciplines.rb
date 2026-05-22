class CreateTrainerDisciplines < ActiveRecord::Migration[8.1]
  def change
    create_table :trainer_disciplines do |t|
      t.references :trainer, null: false, foreign_key: true, index: false
      t.references :discipline, null: false, foreign_key: true

      t.timestamps
    end

    add_index :trainer_disciplines, [ :trainer_id, :discipline_id ], unique: true
  end
end
