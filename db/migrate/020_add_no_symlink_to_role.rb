class AddNoSymlinkToRole < ActiveRecord::Migration
  
  # Added to specify :no_symlink in role --AE 9/26/07
  def self.up
    add_column :roles, :no_symlink, :integer, :default => 0
  end

  def self.down
    remove_column :roles, :no_symlink
  end
end
