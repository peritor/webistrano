module DeploymentsHelper
  
  def input_type(name)
    if name.match(/password/)
      "password"
    else
      'text'
    end
  end
end
