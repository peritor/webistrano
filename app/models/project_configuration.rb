class ProjectConfiguration < ConfigurationParameter
  belongs_to :project
  
  validates_presence_of :project
  validates_uniqueness_of :name, :scope => :project_id
  
  # default templates for Projects
  def self.templates
    {
      'rails' => Webistrano::Template::Rails,
      'mongrel_rails' => Webistrano::Template::MongrelRails,
      'thin_rails' => Webistrano::Template::ThinRails,   
      'mod_rails' => Webistrano::Template::ModRails,
      'pure_file' => Webistrano::Template::PureFile,
      'unicorn' => Webistrano::Template::Unicorn
    }
  end
  
end
