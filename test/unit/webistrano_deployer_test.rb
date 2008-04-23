require File.dirname(__FILE__) + '/../test_helper'

class Webistrano::DeployerTest < Test::Unit::TestCase

  def setup
    @project = create_new_project(:template => 'pure_file')
    @stage = create_new_stage(:project => @project)
    @host = create_new_host
    
    @role = create_new_role(:stage => @stage, :host => @host, :name => 'www')
    
    assert @stage.prompt_configurations.empty?
    
    @deployment = create_new_deployment(:stage => @stage, :task => 'master:do')
  end
  
  def test_initialization    
    # no deployment
    assert_raise(ArgumentError){
      deployer = Webistrano::Deployer.new  
    }
    
    # deployment + role ==> works
    assert_nothing_raised{
      deployer = Webistrano::Deployer.new(@deployment)
    }    
    
    # deployment with no role
    assert_raise(ArgumentError){
      @stage.roles.clear
      assert @deployment.roles(true).empty?
      deployer = Webistrano::Deployer.new(@deployment)
    }
  end
  
  def test_setting_of_configuration_parameters_on_capistrano_configuration
    # create some configuration entries for the stage
    config = @stage.configuration_parameters.build(:name => 'stage_specific', :value => 'xxxxx'); config.save!
    config = @stage.configuration_parameters.build(:name => 'stage_specific2', :value => 'testapp'); config.save!
    
    # create another role for this stage
    app_role = @stage.roles.build(:name => 'app', :host_id => @host.id, :primary => 1)
    app_role.save!
    
    # prepare Mocks
    #
    
    # Logger stubing
    mock_cap_logger = mock
    mock_cap_logger.expects(:level=).with(3)
    
    # config stubbing
    mock_cap_config = mock
    mock_cap_config.stubs(:logger).returns(mock_cap_logger)
    mock_cap_config.stubs(:logger=)
    mock_cap_config.stubs(:load)
    mock_cap_config.stubs(:trigger)
    mock_cap_config.stubs(:find_and_execute_task)
    mock_cap_config.stubs(:[])
    mock_cap_config.stubs(:fetch).with(:scm)
    
    # now the interesting part
    # variable setting
    mock_cap_config.expects(:set).with(:password, nil) # default by Cap
    mock_cap_config.expects(:set).with(:webistrano_project, @project.name)
    mock_cap_config.expects(:set).with(:webistrano_stage, @stage.name)
    
    # now we expect our Vars to be set
    # project vars
    ProjectConfiguration.templates['pure_file']::CONFIG.each do |k, v|
      if k.to_sym == :application
        mock_cap_config.expects(:set).with(k, Webistrano::Deployer.type_cast( @project.name ) )
      else
        mock_cap_config.expects(:set).with(k, Webistrano::Deployer.type_cast(v) )
      end
    end
    
    # stage vars and logger
    mock_cap_config.expects(:set).with{|x, y|
      case x
      when :stage_specific
        y == 'xxxxx'
      when :stage_specific2
        y == 'testapp'
      when :logger
        y.is_a? Webistrano::Logger
      when :real_revision
        true
      else
        false
      end
    }.times(4)
            
    # roles
    mock_cap_config.expects(:role).with('www', @host.name)
    mock_cap_config.expects(:role).with('app', @host.name, {:primary => true})
    
    # main mock install
    Webistrano::Configuration.expects(:new).returns(mock_cap_config)
    
    # get things started
    deployer = Webistrano::Deployer.new( create_new_deployment(:stage => @stage) )
    deployer.invoke_task!
  end
  
  def test_role_attributes
    # prepare stage + roles
    @stage = create_new_stage
    
    www_role = @stage.roles.build(:name => 'www', :host_id => @host.id, :primary => 1, :no_release => 0)
    www_role.save!
    assert !www_role.no_release?
    assert www_role.primary?
    
    app_role = @stage.roles.build(:name => 'app', :host_id => @host.id, :primary => 0, :no_release => 1, :ssh_port => '99')
    app_role.save!
    assert app_role.no_release?
    assert !app_role.primary?
    
    db_role = @stage.roles.build(:name => 'db', :host_id => @host.id, :primary => 1, :no_release => 1, :ssh_port => 44)
    db_role.save!    
    assert db_role.no_release?
    assert db_role.primary?
    
    # prepare Mocks
    #
    
    # Logger stubing
    mock_cap_logger = mock
    mock_cap_logger.expects(:level=).with(3)
    
    # config stubbing
    mock_cap_config = mock
    mock_cap_config.stubs(:logger).returns(mock_cap_logger)
    mock_cap_config.stubs(:logger=)
    mock_cap_config.stubs(:load)
    mock_cap_config.stubs(:trigger)
    mock_cap_config.stubs(:find_and_execute_task)
    mock_cap_config.stubs(:[])
    mock_cap_config.stubs(:fetch).with(:scm)
    
    # ignore vars
    mock_cap_config.stubs(:set)
      
    #  
    # now check the roles        
    # 
    mock_cap_config.expects(:role).with('www', @host.name, {:primary => true})
    mock_cap_config.expects(:role).with('app', @host.name + ":99", {:no_release => true})
    mock_cap_config.expects(:role).with('db', @host.name + ":44", {:no_release => true, :primary => true})
    
    # main mock install
    Webistrano::Configuration.expects(:new).returns(mock_cap_config)
    
    # get things started
    deployer = Webistrano::Deployer.new( create_new_deployment(:stage => @stage) )
    deployer.invoke_task!
  end
  
  def test_excluded_hosts
    # prepare stage + roles
    @stage = create_new_stage
    dead_host = create_new_host
    
    www_role = @stage.roles.build(:name => 'www', :host_id => @host.id)
    www_role.save!
    
    app_role = @stage.roles.build(:name => 'app', :host_id => @host.id)
    app_role.save!
    
    db_role = @stage.roles.build(:name => 'db', :host_id => dead_host.id)
    db_role.save!    

    @stage.reload

    deployment = create_new_deployment(:stage => @stage, :excluded_host_ids => [dead_host.id])
    assert_equal [www_role, app_role].map(&:id).sort, deployment.deploy_to_roles.map(&:id).sort
    # prepare Mocks
    #
    
    # Logger stubing
    mock_cap_logger = mock
    mock_cap_logger.expects(:level=).with(3)
    
    # config stubbing
    mock_cap_config = mock
    mock_cap_config.stubs(:logger).returns(mock_cap_logger)
    mock_cap_config.stubs(:logger=)
    mock_cap_config.stubs(:load)
    mock_cap_config.stubs(:trigger)
    mock_cap_config.stubs(:find_and_execute_task)
    mock_cap_config.stubs(:[])
    mock_cap_config.stubs(:fetch).with(:scm)
    
    # ignore vars
    mock_cap_config.stubs(:set)
      
    #  
    # now check the roles        
    # 
    
    #mock_cap_config.expects(:role).with('db', @host.name)
    mock_cap_config.expects(:role).with('www', @host.name)
    mock_cap_config.expects(:role).with('app', @host.name)
    
    
    # main mock install
    Webistrano::Configuration.expects(:new).returns(mock_cap_config)
    
    # get things started
    deployer = Webistrano::Deployer.new( deployment )
    deployer.invoke_task!
  end
  
  def test_invoke_task
    assert_correct_task_called('deploy:setup')
    assert_correct_task_called('deploy:update')
    assert_correct_task_called('deploy:restart')
    assert_correct_task_called('deploy:stop')
    assert_correct_task_called('deploy:start')
  end
  
  def test_type_cast
    
    assert_equal '', Webistrano::Deployer.type_cast('')
    assert_equal nil, Webistrano::Deployer.type_cast('nil')
    assert_equal true, Webistrano::Deployer.type_cast('true')
    assert_equal false, Webistrano::Deployer.type_cast('false')
    assert_equal :sym, Webistrano::Deployer.type_cast(':sym')
    assert_equal 'abc', Webistrano::Deployer.type_cast('abc')
    assert_equal '/usr/local/www', Webistrano::Deployer.type_cast('/usr/local/www')
    assert_equal 'https://svn.domain.com', Webistrano::Deployer.type_cast('https://svn.domain.com')
    assert_equal 'svn+ssh://svn.domain.com/svn', Webistrano::Deployer.type_cast('svn+ssh://svn.domain.com/svn')
    assert_equal 'la le lu 123', Webistrano::Deployer.type_cast('la le lu 123')
    
    # document that arrays are not cast correct
    assert_equal '[1, 2, 3, 4]', Webistrano::Deployer.type_cast('[1, 2, 3, 4]')
  end
  
  def test_task_invokation_successful
    prepare_config_mocks
    
    @deployment = create_new_deployment(:stage => @stage, :task => 'deploy:update')
    
    deployer = Webistrano::Deployer.new(@deployment)
    deployer.invoke_task!
    
    assert_equal @stage, @deployment.stage
    assert_equal [@role.id], @deployment.roles.collect(&:id)
    assert_equal 'deploy:update', @deployment.task
    assert @deployment.completed?
    assert @deployment.success?
  end
  
  def test_task_invokation_not_successful
    # prepare mocks
    #
    
    # Logger stubing
    mock_cap_logger = mock
    mock_cap_logger.expects(:level=).with(3)

    # config stubbing
    mock_cap_config = mock
    mock_cap_config.stubs(:logger).returns(mock_cap_logger)
    mock_cap_config.stubs(:logger=)
    mock_cap_config.stubs(:load)
    mock_cap_config.stubs(:trigger)
    mock_cap_config.stubs(:[])
    mock_cap_config.stubs(:fetch).with(:scm)

    # vars
    mock_cap_config.stubs(:set)

    # roles
    mock_cap_config.stubs(:role)
    
    # the fun part
    # task execution throws an exception
    mock_cap_config.expects(:find_and_execute_task).raises(Capistrano::Error, 'sorry - no capistrano today')

    # main mock install
    Webistrano::Configuration.expects(:new).returns(mock_cap_config)
    
    @deployment = create_new_deployment(:stage => @stage, :task => 'deploy:update')
    
    deployer = Webistrano::Deployer.new(@deployment)
    deployer.invoke_task!
    
    assert_equal 'deploy:update', @deployment.task
    assert @deployment.completed?
    assert !@deployment.success?
    
    # check error message
    assert_match /sorry - no capistrano today/, @deployment.log
  end
  
  def test_db_logging
    @deployment = create_new_deployment(:stage => @stage, :task => 'deploy:update')
    
    # mocks
    mock_namespace = mock
    mock_namespace.stubs(:default_task)
    mock_namespace.stubs(:search_task)
    
    mock_task = mock
    mock_task.stubs(:namespace).returns(mock_namespace)
    mock_task.stubs(:body).returns(Proc.new{ Proc.new{} })
    mock_task.stubs(:fully_qualified_name).returns('deploy:update')
    mock_task.stubs(:name).returns('deploy:update')
    
    mock_cap_config = Webistrano::Configuration.new
    mock_cap_config.logger = Webistrano::Logger.new(@deployment)
    mock_cap_config.expects(:find_task).returns(mock_task)
    
    # main mock install
    Webistrano::Configuration.expects(:new).returns(mock_cap_config)
    
    # do a random deploy
    deployer = Webistrano::Deployer.new(@deployment)
    deployer.invoke_task!
    
    # the log in the DB should not be empty
    @deployment.reload
    assert_equal "  * executing `deploy:update'\n", @deployment.log
  end
  
  def test_db_logging_if_task_vars_incomplete
    # create a deployment
    @deployment = create_new_deployment(:stage => @stage, :task => 'deploy:default')
 
    # and after creation
    # prepare stage configuration to miss important vars
    @project.configuration_parameters.delete_all
    @stage.configuration_parameters.delete_all
 
    deployer = Webistrano::Deployer.new(@deployment)
    deployer.invoke_task!
    
    # the log in the DB should not be empty
    @deployment.reload
    assert_match /Please specify the repository that houses your application's code, set :repository, 'foo'/, @deployment.log # ' fix highlighting
  end
  
  def test_config_logger_and_real_revision_are_set
    # prepare the stage by creating a nearly blank config
    @project.configuration_parameters.delete_all
    @stage.configuration_parameters.delete_all
    
    conf = @stage.configuration_parameters.build(:name => 'application', :value => 'test')
    conf.save!
    conf = @stage.configuration_parameters.build(:name => 'repository', :value => 'file:///tmp/')
    conf.save!
    
    @deployment = create_new_deployment(:stage => @stage, :task => 'deploy:default')
    # prepare Mocks
    #

    # Logger stubing
    mock_cap_logger = mock
    mock_cap_logger.expects(:level=).with(3)

    # config stubbing
    mock_cap_config = mock
    mock_cap_config.stubs(:logger).returns(mock_cap_logger)
    mock_cap_config.stubs(:logger=)
    mock_cap_config.stubs(:load)
    mock_cap_config.stubs(:trigger)
    mock_cap_config.stubs(:find_and_execute_task)
    mock_cap_config.stubs(:[])
    mock_cap_config.stubs(:fetch).with(:scm)

    # roles
    mock_cap_config.stubs(:role)

    #
    # now the interesting part
    # check that the logger and real_revision were set
    # 
    # vars
    mock_cap_config.expects(:set).with{|x,y|
      if x == :logger
        (y.is_a? Webistrano::Logger)
      else
        [:password, :application, :repository, :real_revision, :webistrano_stage, :webistrano_project].include?(x)
      end
    }.times(7)

    # main mock install
    Webistrano::Configuration.expects(:new).returns(mock_cap_config)

    # get things started
    deployer = Webistrano::Deployer.new(@deployment)
    deployer.invoke_task!
  end
    
  def test_handling_of_scm_error
    # prepare
    project = create_new_project(:template => 'rails')
    stage = create_new_stage(:project => @project)
    host = create_new_host(:name => '127.0.0.1')
    app_role = create_new_role(:name => 'app', :host => host, :stage => stage)
    www_role = create_new_role(:name => 'www', :host => host, :stage => stage)
    db_role = create_new_role(:name => 'db', :host => host, :stage => stage, :primary => 1)
    
    # mock Open4 to return an error
    mock_status = mock
    mock_status.expects(:exitstatus).returns(1)
    Open4.expects(:popen4).returns(mock_status)
    
    deployment = create_new_deployment(:stage => stage, :task => 'deploy:default')
    deployer = Webistrano::Deployer.new(deployment)
    deployer.invoke_task!
    
    deployment.reload
    assert_match /Local scm command failed/, deployment.log
  end
  
  def test_handling_of_open_scm_command_error
    # prepare
    project = create_new_project(:template => 'rails')
    stage = create_new_stage(:project => @project)
    host = create_new_host(:name => '127.0.0.1')
    app_role = create_new_role(:name => 'app', :host => host, :stage => stage)
    www_role = create_new_role(:name => 'www', :host => host, :stage => stage)
    db_role = create_new_role(:name => 'db', :host => host, :stage => stage, :primary => 1)
    
    # set the scm_command to something bogus in order to throw an error
    stage.configuration_parameters.build(:name => 'scm_command', :value => '/tmp/foobar_scm_command').save!
    
    deployment = create_new_deployment(:stage => stage, :task => 'deploy:default')
    deployer = Webistrano::Deployer.new(deployment)
    deployer.invoke_task!
    
    deployment.reload
    assert_match /Local scm command not found/, deployment.log
  end
  
  
  #
  # helper methods
  #
  
  def assert_correct_task_called(task_name)
    @deployment = create_new_deployment(:stage => @stage, :task => task_name)
    # prepare Mocks
    #

    # Logger stubing
    mock_cap_logger = mock
    mock_cap_logger.expects(:level=).with(3)

    # config stubbing
    mock_cap_config = mock
    mock_cap_config.stubs(:logger).returns(mock_cap_logger)
    mock_cap_config.stubs(:logger=)
    mock_cap_config.stubs(:load)
    mock_cap_config.stubs(:trigger)
    mock_cap_config.stubs(:[])
    mock_cap_config.stubs(:fetch).with(:scm)

    # vars
    mock_cap_config.stubs(:set)

    # roles
    mock_cap_config.stubs(:role)

    # now the interesting part, the task
    mock_cap_config.expects(:find_and_execute_task).with(task_name, {:after => :finish, :before => :start})

    # main mock install
    Webistrano::Configuration.expects(:new).returns(mock_cap_config)

    # get things started
    deployer = Webistrano::Deployer.new(@deployment)
    deployer.invoke_task!
  end
  
  def test_handling_of_prompt_configuration
    stage_with_prompt = create_new_stage(:name => 'prod', :project => @project)
    role = create_new_role(:stage => stage_with_prompt)
    assert stage_with_prompt.deployment_possible?, stage_with_prompt.deployment_problems.inspect
    
    # add a config value that wants a promp
    stage_with_prompt.configuration_parameters.build(:name => 'password', :prompt_on_deploy => 1).save!
    assert !stage_with_prompt.prompt_configurations.empty?
    
    # create the deployment
    deployment = create_new_deployment(:stage => stage_with_prompt, :task => 'deploy', :prompt_config => {:password => '123'})
    
    deployer = Webistrano::Deployer.new(deployment)
    deployer.invoke_task!
  end
  
  def test_loading_of_template_tasks
    @project.template = 'mongrel_rails'
    @project.save!
    
    # Logger stubing
    mock_cap_logger = mock
    mock_cap_logger.expects(:level=).with(3)

    # config stubbing
    mock_cap_config = mock
    mock_cap_config.stubs(:trigger)
    mock_cap_config.stubs(:logger).returns(mock_cap_logger)
    mock_cap_config.stubs(:logger=)
    mock_cap_config.stubs(:find_and_execute_task)
    mock_cap_config.stubs(:[])
    mock_cap_config.stubs(:fetch).with(:scm)

    # vars
    mock_cap_config.stubs(:set)

    # roles
    mock_cap_config.stubs(:role)
    
    #
    # now the interestin part, load
    #
    mock_cap_config.expects(:load).with('standard')
    mock_cap_config.expects(:load).with('deploy')
    mock_cap_config.expects(:load).with(:string => @project.tasks )

    # main mock install
    Webistrano::Configuration.expects(:new).returns(mock_cap_config)
    
    #
    # start 
    
    
    deployer = Webistrano::Deployer.new(@deployment)
    deployer.invoke_task!
  end
  
  def test_custom_recipes
    recipe_1 = create_new_recipe(:name => 'Copy config files', :body => 'foobar here')
    @stage.recipes << recipe_1
    
    recipe_2 = create_new_recipe(:name => 'Merge JS files', :body => 'more foobar here')
    @stage.recipes << recipe_2
    
    assert_equal [@stage], recipe_1.stages
    assert_equal [@stage], recipe_2.stages
    
    # Logger stubing
    mock_cap_logger = mock
    mock_cap_logger.expects(:level=).with(3)

    # config stubbing
    mock_cap_config = mock
    mock_cap_config.stubs(:trigger)
    mock_cap_config.stubs(:logger).returns(mock_cap_logger)
    mock_cap_config.stubs(:logger=)
    mock_cap_config.stubs(:find_and_execute_task)
    mock_cap_config.stubs(:[])
    mock_cap_config.stubs(:fetch).with(:scm)

    # vars
    mock_cap_config.stubs(:set)

    # roles
    mock_cap_config.stubs(:role)
    
    #
    # now the interestin part, load
    #
    mock_cap_config.expects(:load).with('standard')
    mock_cap_config.expects(:load).with('deploy')
    mock_cap_config.expects(:load).with(:string => @project.tasks )
    mock_cap_config.expects(:load).with(:string => recipe_1.body )
    mock_cap_config.expects(:load).with(:string => recipe_2.body )

    # main mock install
    Webistrano::Configuration.expects(:new).returns(mock_cap_config)
    
    #
    # start 
    
    deployer = Webistrano::Deployer.new(@deployment)
    deployer.invoke_task!
  end
  
  def test_handling_of_exceptions_during_command_execution
    # Logger stubing
    mock_cap_logger = mock
    mock_cap_logger.expects(:level=).with(3)

    # config stubbing
    mock_cap_config = mock
    mock_cap_config.stubs(:trigger)
    mock_cap_config.stubs(:logger).returns(mock_cap_logger)
    mock_cap_config.stubs(:logger=)
    mock_cap_config.stubs(:[])
    mock_cap_config.stubs(:load)
    mock_cap_config.stubs(:fetch).with(:scm)

    # vars
    mock_cap_config.stubs(:set)

    # roles
    mock_cap_config.stubs(:role)
    
    # interesting part, unexpected exception (e.g. non-SSH, non-Capistrano)
    mock_cap_config.expects(:find_and_execute_task).raises(RuntimeError)
    
    # main mock install
    Webistrano::Configuration.expects(:new).returns(mock_cap_config)
    
    #
    # start 
    
    deployer = Webistrano::Deployer.new(@deployment)
    deployer.invoke_task!
    
    @deployment.reload
    assert_match /RuntimeError/, @deployment.log
  end
  
  def test_setting_of_project_and_stage_name
    # set project/stage names
    @project.name = "MySampleProject"
    @project.save!
    
    @stage.name = "MySample Stage 12"
    @stage.save!
    
    # delete all variables
    @project.configuration_parameters.delete_all
    @stage.configuration_parameters.delete_all
    
    # Logger stubing
    mock_cap_logger = mock
    mock_cap_logger.expects(:level=).with(3)

    # config stubbing
    mock_cap_config = mock
    
    mock_cap_config.stubs(:load)
    mock_cap_config.stubs(:trigger)
    mock_cap_config.stubs(:logger).returns(mock_cap_logger)
    mock_cap_config.stubs(:logger=)
    mock_cap_config.stubs(:find_and_execute_task)
    mock_cap_config.stubs(:[])
    mock_cap_config.stubs(:fetch).with(:scm)

    # roles
    mock_cap_config.stubs(:role)
    
    # override the configs set in order to let normal set operations happen 
    # and check project/stage name
    $vars_set = {}
    def mock_cap_config.set(key, val=nil)
      $vars_set[key] = val
    end

    # 
    #mock_cap_config.expects(:set).with(:webistrano_project, 'MySampleProject')
    #mock_cap_config.expects(:set).with(:webistrano_stage, 'MySampleStage')
    
    # main mock install
    Webistrano::Configuration.expects(:new).returns(mock_cap_config)
    
    # run
    deployer = Webistrano::Deployer.new(@deployment)
    deployer.invoke_task!
    
    # check that the correct project/stage name was set
    assert_equal "my_sample_project", $vars_set[:webistrano_project]
    assert_equal "my_sample_stage_12", $vars_set[:webistrano_stage]
  end
  
  # test that we do not throw an exception if sudo is used
  def test_sudo_callback_behaviour
    # original Capistrano Config
    assert_not_nil Capistrano::Configuration.default_io_proc
    assert Capistrano::Configuration.default_io_proc.is_a?(Proc)
    
    # Webistrano Config
    assert_not_nil Webistrano::Configuration.default_io_proc
    assert Webistrano::Configuration.default_io_proc.is_a?(Proc)
  end
  
  def test_ssh_options
    c = @project.configuration_parameters.build(
      :name => 'ssh_port', 
      :value => '44'
    )
    c.save!
    
    
    deployer = Webistrano::Deployer.new(@deployment)
    
    deployer.expects(:execute_requested_actions).returns(nil)
        
    deployer.invoke_task!
  end
  
  def test_exchange_revision_with_git
    config = @stage.configuration_parameters.build(:name => 'scm', :value => 'git')
    config.save!
    
    
    deployer = Webistrano::Deployer.new(@deployment)
    
    # check that exchange_real_revision is NOT called with git
    deployer.expects(:exchange_real_revision).times(0)
    
    # mock the main exec
    deployer.expects(:execute_requested_actions).returns(nil)
        
    deployer.invoke_task!
  end
  
  def test_exchange_revision_without_git
    config = @stage.configuration_parameters.build(:name => 'scm', :value => 'svn')
    config.save!
    
    
    deployer = Webistrano::Deployer.new(@deployment)
    
    # check that exchange_real_revision is called without git
    deployer.expects(:exchange_real_revision).times(1)
    
    # mock the main exec
    deployer.expects(:execute_requested_actions).returns(nil)
        
    deployer.invoke_task!
  end
  
  def test_list_tasks
    d = Deployment.new
    d.stage = @stage
    deployer = Webistrano::Deployer.new(d)
    
    assert_not_nil deployer.list_tasks
    assert_equal 23, deployer.list_tasks.size
    assert_equal 21, @stage.list_tasks.size # filter shell and invoke
    deployer.list_tasks.each{|t| assert t.is_a?(Capistrano::TaskDefinition) }
    
    # add a stage recipe
    recipe_body = <<-EOS
      namespace :foo do
        task :bar do
          run 'foobar'
        end
      end
    EOS
    recipe = create_new_recipe(:name => 'A new recipe', :body => recipe_body)
    @stage.recipes << recipe
        
    assert_equal 24, deployer.list_tasks.size
    assert_equal 22, @stage.list_tasks.size # filter shell and invoke
    assert_equal 1, deployer.list_tasks.delete_if{|t| t.fully_qualified_name != 'foo:bar'}.size
    assert_equal 1, @stage.list_tasks.delete_if{|t| t[0] != 'foo:bar'}.size
  end
  
  
  protected
  
  # mocks the Capistrano config so that it does not care about anything
  def prepare_config_mocks

    # Logger stubing
    mock_cap_logger = mock
    mock_cap_logger.expects(:level=).with(3)

    # config stubbing
    mock_cap_config = mock
    
    mock_cap_config.stubs(:load)
    mock_cap_config.stubs(:trigger)
    mock_cap_config.stubs(:logger).returns(mock_cap_logger)
    mock_cap_config.stubs(:logger=)
    mock_cap_config.stubs(:find_and_execute_task)
    mock_cap_config.stubs(:[])
    mock_cap_config.stubs(:fetch).with(:scm)

    # vars
    mock_cap_config.stubs(:set)

    # roles
    mock_cap_config.stubs(:role)

    # main mock install
    Webistrano::Configuration.expects(:new).returns(mock_cap_config)
  end
  
end