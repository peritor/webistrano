class AddCanManageFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :manage_hosts, :boolean, :default => false
    add_column :users, :manage_recipes, :boolean, :default => false
    add_column :users, :manage_users, :boolean, :default => false
    add_column :users, :manage_stages, :boolean, :default => false
    add_column :users, :manage_projects, :boolean, :default => false
  end

  def self.down
    remove_column :users, :manage_hosts
    remove_column :users, :manage_recipes
    remove_column :users, :manage_users
    remove_column :users, :manage_stages
    remove_column :users, :manage_projects
  end
end
