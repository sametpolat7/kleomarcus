class CreateMembershipPlans < ActiveRecord::Migration[8.1]
  def change
    create_table :membership_plans do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.integer :monthly_price, null: false
      t.string :features, array: true, default: [], null: false
      t.boolean :featured, default: false, null: false
      t.integer :position, null: false

      t.timestamps
    end

    add_index :membership_plans, :name, unique: true
    add_index :membership_plans, :position, unique: true

    reversible do |direction|
      direction.up do
        MembershipPlan.reset_column_information
        load Rails.root.join("db/seeds/membership_plans.rb")
      end
    end
  end
end
