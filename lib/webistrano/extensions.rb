class Object
  
  # hack abort to log to DB and exit Capistrano in a clean way
  # that can be catched by Webistrano::Deployer
  alias :original_abort :abort
  
  def abort(msg=nil)
    if (defined? @logger)
  
      # log msg to DB
      logger.important(msg)
      
      # use throw to fake a go-to in order to mimic aborts behaviour
      # in aborting the current context but still be catchable (by catch)
      throw :abort_called_by_capistrano, :capistrano_abort
    else
      original_abort(msg)
    end
  end
  
end