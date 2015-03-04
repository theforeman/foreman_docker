class RemoveKatelloFlagFromContainers < ActiveRecord::Migration
  def up
    remove_column :containers, :katello
  end

  def down
    add_column :containers, :katello, :boolean
  end
end
