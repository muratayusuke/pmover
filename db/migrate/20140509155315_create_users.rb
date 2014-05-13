class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :email, null: true
      t.string :token, null: true

      t.timestamps
    end

    add_index :users, [:provider, :uid], unique: true
  end
end
