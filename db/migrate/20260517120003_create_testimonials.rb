class CreateTestimonials < ActiveRecord::Migration[8.1]
  def change
    create_table :testimonials do |t|
      t.string :author_name, null: false
      t.string :title
      t.text :content, null: false
      t.integer :rating, null: false, default: 5

      t.timestamps
    end
  end
end
