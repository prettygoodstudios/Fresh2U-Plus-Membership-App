class AddAttrToMember < ActiveRecord::Migration[5.1]
  def change
    add_column :members, :salt, :string
    add_column :members, :transaction_token, :string
  end
end
