class AddDisabledToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :disabled, :timestamp
    add_index :users, :disabled
  end

  def self.down
    remove_index :users, :disabled
    remove_column :users, :disabled
  end
end
