class AddSlugToDisciplines < ActiveRecord::Migration[8.1]
  def up
    add_column :disciplines, :slug, :string

    # Backfill slugs for existing disciplines from their (Turkish) names.
    Discipline.reset_column_information
    Discipline.find_each do |discipline|
      discipline.update_columns(slug: Discipline.slugify(discipline.name))
    end

    change_column_null :disciplines, :slug, false
    add_index :disciplines, :slug, unique: true
  end

  def down
    remove_index :disciplines, :slug
    remove_column :disciplines, :slug
  end
end
