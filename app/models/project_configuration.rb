class ProjectConfiguration < ConfigurationParameter
  belongs_to :project
  
  validates_presence_of :project
  validates_uniqueness_of :name, :scope => :project_id
  
  # default templates for Projects
  def self.templates
    {
      'rails' => Webistrano::Template::Rails,
      'mongrel_rails' => Webistrano::Template::MongrelRails,
      'pure_file' => Webistrano::Template::PureFile
    }
  end
  
end
