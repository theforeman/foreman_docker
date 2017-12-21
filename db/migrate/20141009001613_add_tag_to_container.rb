class AddTagToContainer < ActiveRecord::Migration[4.2]
  def change
    add_column :containers, :tag, :string
  end
end
