class CreateStages < ActiveRecord::Migration
  def self.up
    create_table :stages do |t|
      t.column :name, :string
      t.column :project_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :stages
  end
end
