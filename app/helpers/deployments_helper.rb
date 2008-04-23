module DeploymentsHelper
  
  def input_type(name)
    if name.match(/password/)
      "password"
    else
      'text'
    end
  end
  
  def if_disabled_host?(host, text)
    (@deployment.excluded_host_ids.include?(host.id) ? text : '' rescue '')
  end
  
  def if_enabled_host?(host, text)
    (@deployment.excluded_host_ids.include?(host.id) ? '' : text rescue text)
  end
end
