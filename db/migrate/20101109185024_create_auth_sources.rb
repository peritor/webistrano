class CreateAuthSources < ActiveRecord::Migration
  def self.up
    create_table "auth_sources", :force => true do |t|
      t.column "type", :string, :limit => 30, :default => "", :null => false
      t.column "name", :string, :limit => 60, :default => "", :null => false
      t.column "host", :string, :limit => 60
      t.column "port", :integer
      t.column "account", :string, :limit => nil
      t.column "account_password", :string, :limit => 60
      t.column "base_dn", :string, :limit => 255
      t.column "attr_login", :string, :limit => 30
      t.column "attr_firstname", :string, :limit => 30
      t.column "attr_lastname", :string, :limit => 30
      t.column "attr_mail", :string, :limit => 30
      t.column "onthefly_register", :boolean, :default => false, :null => false
      t.column 'tls', :boolean, :default => false, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :auth_sources
  end
end
