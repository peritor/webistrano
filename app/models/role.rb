class Role < ActiveRecord::Base
  belongs_to :stage
  belongs_to :host
  has_and_belongs_to_many :deployments
  
  validates_presence_of :stage, :name, :host, :no_release, :primary, :no_symlink
  validates_length_of :name, :maximum => 250
  validates_inclusion_of :primary, :in => 0..1
  validates_inclusion_of :no_release, :in => 0..1
  validates_inclusion_of :no_symlink, :in => 0..1
  validates_uniqueness_of :name, :scope => [:host_id, :stage_id, :ssh_port], :message => 'already used with this host.'
  
  attr_accessible :name, :primary, :host_id, :no_release, :no_symlink, :ssh_port, :custom_name
  
  attr_accessor :custom_name
  
  DEFAULT_NAMES = %w(app db web)
  
  before_validation :set_name_from_custom_name
  
  def set_name_from_custom_name
    self.name = self.custom_name unless self.custom_name.blank?
  end
  
  def custom_name
    if @custom_name.blank? && self.custom_name?
      @custom_name = self.name
    end
    @custom_name
  end
    
  def custom_name?
    return false if self.name.blank?
    !DEFAULT_NAMES.include?(self.name)
  end
  
  def primary?
    self.primary.to_i == 1
  end
  
  def set_as_primary!
    self.primary = 1
    self.save!
  end
  
  def unset_as_primary!
    self.primary = 0
    self.save!
  end
  
  def no_release?
    self.no_release.to_i == 1
  end
  
  def set_no_release!
    self.no_release = 1
    self.save!
  end
  
  def unset_no_release!
    self.no_release = 0
    self.save!
  end
    
  def no_symlink?
    self.no_symlink.to_i == 1
  end
  
  def set_no_symlink!
    self.no_symlink = 1
    self.save!
  end
  
  def unset_no_symlink!
    self.no_symlink = 0
    self.save!
  end
  
  # tells if this role had a successful setup
  def setup_done?
    deployed_at_least_once? && self.deployments.exists?(:conditions => {"deployments.task" => Deployment::SETUP_TASKS, "deployments.status" => Deployment::STATUS_SUCCESS})
  end
  
  # tells if this role had a successful deployment (deploy)
  def deployed?
    deployed_at_least_once? && self.deployments.exists?(:conditions => {"deployments.task" => Deployment::DEPLOY_TASKS, "deployments.status" => Deployment::STATUS_SUCCESS})
  end
  
  # tells if this role had any deployment at all
  def deployed_at_least_once?
    self.deployments.exists?
  end
  
  def status
    if !self.deployed_at_least_once? || (!self.deployed? && !self.setup_done? )
      'blank'
    else
      if self.setup_done? && !self.deployed? 
        'setup done'
      elsif self.deployed_at_least_once? # self.deployed? && self.setup_done?
        'deployed'
      else
        raise "unknown status for role #{self.id}: #{self.attributes.inspect}"
      end
    end
  end
  
  def status_in_html
    "<span class='role_status_#{self.status.gsub(/ /, '_')}'>#{self.status}</span>"
  end
  
  def role_attribute_hash
    role_attr = {}
    if self.primary?
      role_attr[:primary] = true
    end
    if self.no_release?
      role_attr[:no_release] = true
    end
    if self.no_symlink?
      role_attr[:no_symlink] = true
    end
    role_attr
  end
    
  def hostname_and_port
    if self.ssh_port.blank?
      self.host.name
    else
      "#{self.host.name}:#{self.ssh_port}"
    end
  end
  
end
