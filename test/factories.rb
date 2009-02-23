module Factories
  
  # returns a random string for testing
  def random_string(size=10)
    rand_array = []
    "a".upto("z"){|e| rand_array << e}
    
    result = ""
    size.times do
      result += (rand_array[rand(rand_array.size) - 1])
    end 
    
    return result
  end
  
  def create_new_host(options = {})
    options = {
      :name => "#{(rand(999) % 255)}.#{(rand(999) % 255)}.#{(rand(999) % 255)}.#{(rand(999) % 255)}"
    }.update(options)
  
    h = Host.new
    h.name = options[:name]
    h.save!
  
    return h
  end

  def create_new_project(options = {})
    options = {
      :name => random_string,
      :description => random_string,
      :template => 'rails'
    }.update(options)
  
    p = Project.new
    p.name = options[:name]
    p.description = options[:description]
    p.template = options[:template]
    p.save!
  
  
    return p
  end

  def create_new_stage(options = {})
    options = {
      :project => create_new_project,
      :name => random_string
    }.update(options)
  
    s = Stage.new
    s.name = options[:name]
    s.project = options[:project]
    s.save!
  
    return s
  end

  # def create_new_role(options = {})
  #   options = {
  #     :stage => create_new_stage,
  #     :host => create_new_host,
  #     :name => random_string,
  #     :primary => 0
  #   }.update(options)
  #   
  #   r = Role.new
  #   r.name = options[:name]
  #   r.stage = options[:stage]
  #   r.host = options[:host]
  #   r.primary = options[:primary]
  #   r.save!
  #   
  #   return r
  # end

  def create_new_project_configuration(options = {})
    options = {
      :project => create_new_project,
      :name => random_string,
      :value => random_string,
      :prompt_on_deploy => 0
    }.update(options)
  
    pc = ProjectConfiguration.new
    pc.name = options[:name]
    pc.value = options[:value]
    pc.prompt_on_deploy = options[:prompt_on_deploy]
    pc.project = options[:project]
  
    pc.save!
  
    return pc
  end

  def create_new_stage_configuration(options = {})
    options = {
      :stage => create_new_stage,
      :name => random_string,
      :value => random_string,
      :prompt_on_deploy => 0
    }.update(options)
  
    sc = StageConfiguration.new
    sc.name = options[:name]
    sc.value = options[:value]
    sc.prompt_on_deploy = options[:prompt_on_deploy]
    sc.stage = options[:stage]
  
    sc.save!
  
    return sc
  end

  def create_new_role(options = {})
    options = {
      :stage => create_new_stage,
      :name => random_string,
      :host => create_new_host,
      :primary => 0,
      :no_release => 0,
      :no_symlink => 0
    }.update(options)
  
    r = Role.new
    r.name = options[:name]
    r.host = options[:host]
    r.stage = options[:stage]
    r.primary = options[:primary]
    r.no_release = options[:no_release]
  
    r.save!
  
    return r
  end

  def create_new_user(options = {})
    options = {
      :login => random_string,
      :email => "#{random_string}@#{random_string}.com",
      :password => random_string
    }.update(options)
  
    u = User.new
    u.login = options[:login]
    u.email = options[:email]
    u.password = options[:password]
    u.password_confirmation = options[:login]

    u.save!
  
    return u
  end

  def create_new_deployment(options = {})
    options = {
      :stage => create_new_stage,
      :task => random_string,
      :completed_at => nil,
      :status => 'running',
      :prompt_config => {},
      :roles => [],
      :description => random_string,
      :user => create_new_user,
      :revision => "392",
      :pid => nil,
      :excluded_host_ids => [],
      :override_locking => false
    }.update(options)
  
    d = Deployment.new
    d.task = options[:task]
    d.stage = options[:stage]
    d.completed_at = options[:completed_at]
    d.status = options[:status]
    d.prompt_config = options[:prompt_config]
    d.description = options[:description]
    d.excluded_host_ids = options[:excluded_host_ids]
    d.user = options[:user]
    d.pid = options[:pid]
    d.revision = options[:revision]
    d.override_locking = options[:override_locking]

    d.roles << options[:roles] unless options[:roles].empty?
    d.save!
  
    return d
  end

  def create_new_recipe(options = {})
    options = {
      :name => random_string,
      :description => random_string,
      :body => random_string
    }.update(options)
  
    r = Recipe.new
    r.name = options[:name]
    r.description = options[:description]
    r.body = options[:body]

    r.save!
  
    return r
  end

  def create_new_user(options = {})
    options = {
      :login => random_string,
      :email => "#{random_string}@#{random_string}.com",
      :admin => 0,
      :password => random_string
    }.update(options)
  
    u = User.new
    u.login = options[:login]
    u.email = options[:email]
    u.admin = options[:admin]
    u.password = options[:password]
    u.password_confirmation = options[:password]

    u.save!
  
    return u
  end
  
  def create_stage_with_role
    stage = create_new_stage
    host = create_new_host
    role_app = create_new_role(:name => 'app', :stage => stage, :host => host)
    stage
  end
end