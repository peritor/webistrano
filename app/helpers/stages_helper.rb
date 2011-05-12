module StagesHelper
  
  def display_deployment_problems(stage)
    out =  "<ul>"
    stage.deployment_problems.each do |k,v|
      out += "<li>#{v}</li>"
    end
    out += "</ul>"
    return out
  end
  
  # returns the escaped format of a config value
  def capfile_cast(val)
    casted_val = Webistrano::Deployer.type_cast(val).class

    if casted_val == String || casted_val == ActiveSupport::SafeBuffer
      val.inspect
    elsif casted_val == Symbol
      val.to_s
    elsif casted_val == Array
      val.to_s
    elsif casted_val == Hash
      val.to_s
    elsif (casted_val == TrueClass ) || (casted_val == FalseClass)
      val
    elsif casted_val == NilClass
      'nil'
    end

  end

  
end
