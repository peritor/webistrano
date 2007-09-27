class AddNotifyToStage < ActiveRecord::Migration
  def self.up
    add_column :stages, :alert_emails, :text
  end

  def self.down
    remove_column :stages, :alert_emails
  end
end
