class Recipe < ActiveRecord::Base
  has_and_belongs_to_many :stages
  
  validates_uniqueness_of :name
  validates_presence_of :name, :body
  validates_length_of :name, :maximum => 250
  
  attr_accessible :name, :body, :description
  
  tz_time_attributes :created_at, :updated_at
end
