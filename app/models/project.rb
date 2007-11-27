class Project < ActiveRecord::Base
  has_many :stages, :dependent => :destroy, :order => 'name ASC'
  has_many :deployments, :through => :stages
  has_many :configuration_parameters, :dependent => :destroy, :class_name => "ProjectConfiguration", :order => 'name ASC'
  
  validates_uniqueness_of :name
  validates_presence_of :name
  validates_length_of :name, :maximum => 250
  validates_inclusion_of :template, :in => ProjectConfiguration.templates.keys
  
  after_create :create_template_defaults
  
  attr_accessible :name, :description, :template
  
  tz_time_attributes :created_at, :updated_at
  
  # creates the default configuration parameters based on the template
  def create_template_defaults
    unless template.blank?
      ProjectConfiguration.templates[template]::CONFIG.each do |k, v|
        config = self.configuration_parameters.build(:name => k.to_s, :value => v.to_s)

        if k.to_sym == :application          
          config.value = self.name.gsub(/[^0-9a-zA-Z]/,"_").underscore
        end  
        config.save!
      end
    end
  end
  
  # returns a string with all custom tasks to be loaded by the Capistrano config
  def tasks
    ProjectConfiguration.templates[template]::TASKS
  end
  
  # returns a better form of the project name for use inside Capistrano recipes
  def webistrano_project_name
    self.name.underscore.gsub(/[^a-zA-Z0-9\-\_]/, '_')
  end
    
end
