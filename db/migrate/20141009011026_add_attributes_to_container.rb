class AddAttributesToContainer < ActiveRecord::Migration[4.2]
  def change
    add_column :containers, :entrypoint, :string
    add_column :containers, :cpu_set, :integer
    add_column :containers, :cpu_shares, :float
    add_column :containers, :memory, :integer
    add_column :containers, :tty, :boolean
    add_column :containers, :attach_stdin,  :boolean, :default => true
    add_column :containers, :attach_stdout, :boolean, :default => true
    add_column :containers, :attach_stderr, :boolean, :default => true
  end
end
