class Deployment < ActiveRecord::Base
  belongs_to :stage
  belongs_to :user
  has_and_belongs_to_many :roles
  
  validates_presence_of :task, :stage, :description, :user
  validates_length_of :task, :maximum => 250
  validates_inclusion_of :success, :in => 0..1
  
  serialize :excluded_host_ids
  
  attr_accessible :task, :prompt_config, :description, :excluded_host_ids
  
  tz_time_attributes :created_at, :updated_at, :completed_at
  
  # given configuration hash on create in order to satisfy prompt configurations
  attr_accessor :prompt_config 
  
  after_create :add_stage_roles
  
  DEPLOY_TASKS = ['deploy', 'deploy:default', 'deploy:migrations']
  SETUP_TASKS = ['deploy:setup']
  
    
  # check (on on creation ) that the stage is ready
  # his has to done only on creation as later DB logging MUST always work
  def validate_on_create
    unless self.stage.blank?
      errors.add('stage', 'is not ready to deploy') unless self.stage.deployment_possible?
      
      self.stage.prompt_configurations.each do |conf|
        errors.add('base', "Please fill out the parameter '#{conf.name}'") unless !prompt_config.blank? && !prompt_config[conf.name.to_sym].blank?
      end
      
      ensure_not_all_hosts_excluded
    end
  end
  
  def prompt_config
    @prompt_config = @prompt_config || {}
    @prompt_config
  end
  
  def add_stage_roles
    self.stage.roles.each do |role|
      self.roles << role
    end
  end
  
  def completed?
    !self.completed_at.blank?
  end
  
  def status
    if !self.completed?
      'running'
    else
      self.success? ? 'success' : 'failed'
    end
  end
  
  def status_in_html
    "<span class='deployment_status_#{self.status.gsub(/ /, '_')}'>#{self.status}</span>"
  end
  
  def status_image
    case self.status
    when 'running'
      'status_running_small.gif'
    when 'failed'
      'status_failed_small.png'
    when 'success'
      'status_success_small.png'
    end
  end
  
  def complete_with_error!
    raise 'cannot complete a second time' if self.completed?
    self.success = 0
    self.completed_at = TzTime.now
    self.save!
    
    self.stage.emails.each do |email|
      Notification.deliver_deployment(self, email)
    end
  end
  
  def complete_successfully!
    raise 'cannot complete a second time' if self.completed?
    self.success = 1
    self.completed_at = TzTime.now
    self.save!
    
    self.stage.emails.each do |email|
      Notification.deliver_deployment(self, email)
    end
  end
  
  # deploy through Webistrano::Deployer in background (== other process)
  # TODO - at the moment `Unix &` hack
  def deploy_in_background! 
    unless RAILS_ENV == 'test'   
      RAILS_DEFAULT_LOGGER.info "Calling other ruby process in the background in order to deploy deployment #{self.id} (stage #{self.stage.id}/#{self.stage.name})"
      system("sh -c \"cd #{RAILS_ROOT} && ruby script/runner -e #{RAILS_ENV} ' deployment = Deployment.find(#{self.id}); deployment.prompt_config = #{self.prompt_config.inspect.gsub('"', '\"')} ; Webistrano::Deployer.new(deployment).invoke_task! ' >> #{RAILS_ROOT}/log/#{RAILS_ENV}.log 2>&1\" &")
    end
  end
  
  # returns an unsaved, new deployment with the same task/stage/description
  def repeat
    returning Deployment.new do |d|
      d.stage = self.stage
      d.task = self.task
      d.description = "Repetition of deployment #{self.id}:\n\n" 
      d.description += self.description
    end
  end
  
  # returns a list of hosts that this deployment
  # will deploy to. This computed out of the list
  # of given roles and the excluded hosts
  def deploy_to_hosts
    all_hosts = self.roles.map(&:host).uniq
    return all_hosts - self.excluded_hosts
  end
  
  # returns a list of roles that this deployment
  # will deploy to. This computed out of the list
  # of given roles and the excluded hosts
  def deploy_to_roles(base_roles=self.roles)
    base_roles.dup.delete_if{|role| self.excluded_hosts.include?(role.host) }
  end
  
  # a list of all excluded hosts for this deployment
  # see excluded_host_ids
  def excluded_hosts
    res = []
    self.excluded_host_ids.each do |h_id|
      res << (Host.find(h_id) rescue nil)
    end
    res.compact
  end
  
  def excluded_host_ids
    self.read_attribute('excluded_host_ids').blank? ? [] : self.read_attribute('excluded_host_ids')
  end
  
  def excluded_host_ids=(val)
    val = [val] unless val.is_a?(Array)
    self.write_attribute('excluded_host_ids', val.map(&:to_i))
  end
  
  protected
  def ensure_not_all_hosts_excluded
    unless self.stage.blank? || self.excluded_host_ids.blank?
      if deploy_to_roles(self.stage.roles).blank?
        errors.add('base', "You cannot exclude all hosts.")
      end
    end
  end
end
