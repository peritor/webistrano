require "#{RAILS_ROOT}/app/models/user"

class AddDefaultUser < ActiveRecord::Migration
  def self.up
    unless User.count > 0
      admin = User.new
      admin.login = 'admin'
      admin.email = 'admin@example.com'
      admin.password = 'admin'
      admin.password_confirmation = 'admin'
      admin.admin = 1
      unless admin.save
        puts "Could not create default admin user:"
        admin.errors.each do |att, m|
          puts "#{att}: #{m}"
        end
      end
    end
  end

  def self.down
  end
end
