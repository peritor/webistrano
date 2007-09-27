class AddNoReleaseToRole < ActiveRecord::Migration
  def self.up
    add_column :roles, :no_release, :integer, :default => 0
  end

  def self.down
    remove_column :roles, :no_release
  end
end
