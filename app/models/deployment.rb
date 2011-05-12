class Deployment < ActiveRecord::Base
  belongs_to :stage
  belongs_to :user
  has_and_belongs_to_many :roles
  
  validates_presence_of :task, :stage, :user
  validates_length_of :task, :maximum => 250
  
  serialize :excluded_host_ids
  
  attr_accessible :task, :prompt_config, :description, :excluded_host_ids, :override_locking
    
  # given configuration hash on create in order to satisfy prompt configurations
  attr_accessor :prompt_config
  
  attr_accessor :override_locking
  
  after_create :add_stage_roles
  
  DEPLOY_TASKS    = ['deploy', 'deploy:default', 'deploy:migrations']
  SETUP_TASKS     = ['deploy:setup']
  STATUS_CANCELED = "canceled"
  STATUS_FAILED   = "failed"
  STATUS_SUCCESS  = "success"
  STATUS_RUNNING  = "running"
  STATUS_VALUES   = [STATUS_SUCCESS, STATUS_FAILED, STATUS_CANCELED, STATUS_RUNNING]
  
  validates_inclusion_of :status, :in => STATUS_VALUES
    
  # check (on on creation ) that the stage is ready
  # his has to done only on creation as later DB logging MUST always work
  def validate_on_create
    unless self.stage.blank?
      errors.add('stage', 'is not ready to deploy') unless self.stage.deployment_possible?
      
      self.stage.prompt_configurations.each do |conf|
        errors.add('base', "Please fill out the parameter '#{conf.name}'") unless !prompt_config.blank? && !prompt_config[conf.name.to_sym].blank?
      end
      
      errors.add('lock', 'The stage is locked') if self.stage.locked? && !self.override_locking
      
      ensure_not_all_hosts_excluded
    end
  end
  
  def self.lock_and_fire(&block)
    transaction do
      d = Deployment.new
      block.call(d)
      return false unless d.valid?
      stage = Stage.find(d.stage_id, :lock => true)
      stage.lock
      d.save!
      stage.lock_with(d)
    end
    true
  rescue => e
    RAILS_DEFAULT_LOGGER.debug "DEPLOYMENT: could not fire deployment: #{e.inspect} #{e.backtrace.join("\n")}"
    false
  end
  
  def override_locking?
    @override_locking.to_i == 1
  end
  
  def prompt_config
    @prompt_config = @prompt_config || {}
    @prompt_config
  end
  
  def effective_and_prompt_config
    @effective_and_prompt_config = @effective_and_prompt_config || self.stage.effective_configuration.collect do |conf|
      if prompt_config.has_key?(conf.name)
        conf.value = prompt_config[conf.name] 
      end
      conf
    end
  end
  
  def add_stage_roles
    self.stage.roles.each do |role|
      self.roles << role
    end
  end
  
  def completed?
    !self.completed_at.blank?
  end
  
  def success?
    self.status == STATUS_SUCCESS
  end
  
  def failed?
    self.status == STATUS_FAILED
  end
  
  def canceled?
    self.status == STATUS_CANCELED
  end
  
  def running?
    self.status == STATUS_RUNNING
  end
  
  def status_in_html
    "<span class='deployment_status_#{self.status.gsub(/ /, '_')}'>#{self.status}</span>"
  end

  def complete_with_error!
    save_completed_status!(STATUS_FAILED)
    notify_per_mail
  end
  
  def complete_successfully!
    save_completed_status!(STATUS_SUCCESS)
    notify_per_mail
  end
  
  def complete_canceled!
    save_completed_status!(STATUS_CANCELED)
    notify_per_mail
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
    Deployment.new.tap do |d|
      d.stage = self.stage
      d.task = self.task
      d.description = "Repetition of deployment #{self.id}: \n" 
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
  
  def cancelling_possible?
    !self.pid.blank? && !completed?
  end
  
  def cancel!
    raise "Canceling not possible: Either no PID or already completed" unless cancelling_possible?
    
    Process.kill("SIGINT", self.pid)
    sleep 2
    Process.kill("SIGKILL", self.pid) rescue nil # handle the case that we killed the process the first time
    
    complete_canceled!
  end
  
  def clear_lock_error
    self.errors.instance_variable_get("@errors").delete('lock')
  end
  
  protected
  def ensure_not_all_hosts_excluded
    unless self.stage.blank? || self.excluded_host_ids.blank?
      if deploy_to_roles(self.stage.roles).blank?
        errors.add('base', "You cannot exclude all hosts.")
      end
    end
  end
  
  def save_completed_status!(status)
    raise 'cannot complete a second time' if self.completed?
    transaction do
      stage = Stage.find(self.stage_id, :lock => true)
      stage.unlock
      self.status = status
      self.completed_at = Time.now
      self.save!
    end
  end
  
  def notify_per_mail
    self.stage.emails.each do |email|
      Notification.deliver_deployment(self, email)
    end
  end
end
