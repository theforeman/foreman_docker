class AddTagToContainer < ActiveRecord::Migration
  def change
    add_column :containers, :tag, :string
  end
end
