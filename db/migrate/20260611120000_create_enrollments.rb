class CreateEnrollments < ActiveRecord::Migration[8.1]
  def change
    create_table :enrollments do |t|
      t.references :discipline, null: false, foreign_key: true
      t.string :full_name, null: false
      t.string :phone, null: false
      t.string :email
      t.integer :age, null: false
      t.integer :level, null: false
      t.text :message
      t.integer :status, default: 0, null: false
      t.datetime :kvkk_accepted_at

      t.timestamps
    end

    add_index :enrollments, :status
    add_index :enrollments, :created_at
  end
end
