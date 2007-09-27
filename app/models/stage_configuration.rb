class StageConfiguration < ConfigurationParameter
  belongs_to :stage
  
  validates_presence_of :stage
  validates_uniqueness_of :name, :scope => :stage_id
end
