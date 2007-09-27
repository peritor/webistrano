ActiveRecord::Schema.define(:version => 1) do
  create_table :nodes, :force => true do |t|
    t.column :name, :string
    t.column :parent_id, :integer
  end
  
  create_table :fathers, :force => true do |t|
    t.column :name, :string
  end
  
  create_table :sons, :force => true do |t|
    t.column :name, :string
    t.column :father_id, :integer
  end
  
  create_table :toys, :force => true do |t|
    t.column :name, :string
    t.column :son_id, :integer
  end
  
  create_table :fathers_sons, :force => true, :id => false do |t|
    t.column :father_id, :integer
    t.column :son_id, :integer
  end
end