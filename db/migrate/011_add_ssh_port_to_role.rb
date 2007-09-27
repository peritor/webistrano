class AddSshPortToRole < ActiveRecord::Migration
  def self.up
    add_column :roles, :ssh_port, :integer
  end

  def self.down
    remove_column :roles, :ssh_port
  end
end
