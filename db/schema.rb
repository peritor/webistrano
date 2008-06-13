# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 23) do

  create_table "configuration_parameters", :force => true do |t|
    t.string   "name"
    t.string   "value"
    t.integer  "project_id",       :limit => 11
    t.integer  "stage_id",         :limit => 11
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "prompt_on_deploy", :limit => 11, :default => 0
  end

  create_table "deployments", :force => true do |t|
    t.string   "task"
    t.text     "log"
    t.integer  "success",           :limit => 11, :default => 0
    t.integer  "stage_id",          :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "completed_at"
    t.text     "description"
    t.integer  "user_id",           :limit => 11
    t.string   "excluded_host_ids"
  end

  create_table "deployments_roles", :id => false, :force => true do |t|
    t.integer "deployment_id", :limit => 11
    t.integer "role_id",       :limit => 11
  end

  create_table "hosts", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_configurations", :force => true do |t|
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "template"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recipes", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recipes_stages", :id => false, :force => true do |t|
    t.integer "recipe_id", :limit => 11
    t.integer "stage_id",  :limit => 11
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "stage_id",   :limit => 11
    t.integer  "host_id",    :limit => 11
    t.integer  "primary",    :limit => 11, :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "no_release", :limit => 11, :default => 0
    t.integer  "ssh_port",   :limit => 11
    t.integer  "no_symlink", :limit => 11, :default => 0
  end

  create_table "stage_configurations", :force => true do |t|
  end

  create_table "stages", :force => true do |t|
    t.string   "name"
    t.integer  "project_id",   :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "alert_emails"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.integer  "admin",                     :limit => 11, :default => 0
    t.string   "time_zone",                               :default => "UTC"
  end

end
