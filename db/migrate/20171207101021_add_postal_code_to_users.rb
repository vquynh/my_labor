class AddPostalCodeToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :postal_code, :integer
  end
end
