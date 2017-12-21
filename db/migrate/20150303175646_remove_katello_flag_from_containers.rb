class RemoveKatelloFlagFromContainers < ActiveRecord::Migration[4.2]
  def up
    remove_column :containers, :katello
  end

  def down
    add_column :containers, :katello, :boolean
  end
end
