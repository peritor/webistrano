require 'digest/sha1'
class User < ActiveRecord::Base
  has_many :deployments, :dependent => :nullify, :order => 'created_at DESC'
  has_many :user_project_links, :dependent => :destroy
  has_many :projects, :through => :user_project_links
  belongs_to :auth_source
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  
  attr_accessible :login, :email, :password, :password_confirmation, :time_zone, :tz, :auth_source_id

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  before_save :encrypt_password
  
  scope :enabled, :conditions => {:disabled => nil}
  scope :disabled, :conditions => "disabled IS NOT NULL"

  validate :check_for_last_admin, :on => :update

  def check_for_last_admin
    if User.find(self.id).admin? && !self.admin?
      errors.add('admin', 'status can no be revoked as there needs to be one admin left.') if User.admin_count == 1
    end
  end
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    
    user = User.find_by_login_and_disabled(login, nil)
    
    if user
      if user.local_user?
        return nil unless user.authenticated?(password)
      else
        return nil unless user.auth_source.authenticate(login, password)  
      end
    else
      user = User.try_onthefly_registration(login, password)
    end
    user
  end
  
  def self.try_onthefly_registration(login, password)
    attrs = AuthSource.authenticate(login, password)
    logger.debug "attrs 1: #{attrs.inspect}"
    attrs = attrs.first if attrs.is_a? Array
    logger.debug "attrs 2: #{attrs.inspect}"
    if attrs.present?
      user = User.new
      user.auth_source_id = attrs[:auth_source_id]
      user.email = attrs[:mail]
      user.login = login
      user.save!
      user.reload
      logger.debug "User '#{user.login}' created from external auth source: #{user.auth_source.type} - #{user.auth_source.name}"
    end
    user
  end
  
  def local_user?
    self.auth_source_id.blank?
  end
  
  def remote_user?
    self.auth_source_id.present?
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(:validate => false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(:validate => false)
  end
  
  def admin?
    self.admin.to_i == 1
  end
  
  def revoke_admin!
    self.admin = 0
    self.save!
  end
  
  def make_admin!
    self.admin = 1
    self.save!
  end
  
  def self.admin_count
    count(:id, :conditions => ['admin = 1 AND disabled IS NULL'])
  end
  
  def recent_deployments(limit=3)
    self.deployments.find(:all, :limit => limit, :order => 'created_at DESC')
  end
  
  def disabled?
    !self.disabled.blank?
  end
  
  def disable
    self.update_attribute(:disabled, Time.now)
    self.forget_me
  end
  
  def enable
    self.update_attribute(:disabled, nil)
  end
  
  def can_edit?(obj)
    obj.editable_by?(self)
  end
  
  def can_view?(obj)
    obj.viewable_by?(self)
  end
  
  def can_manage_hosts?
    self.admin? || self.manage_hosts?
  end
  
  def can_manage_recipes?
    self.admin? || self.manage_recipes?
  end
  
  def can_manage_projects?
    self.admin? || self.manage_projects?
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      self.local_user? && WebistranoConfig[:authentication_method] != :cas && (crypted_password.blank? || !password.blank?)
    end

    
end
