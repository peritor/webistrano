class ConfigurationParameter < ActiveRecord::Base
  attr_accessible :name, :value, :prompt_on_deploy
  
  validates_presence_of :name
  validates_inclusion_of :prompt_on_deploy, :in => 0..1
  
  before_validation :empty_value_if_deploy_is_set
  
  def validate
    self.errors.add('value', 'must be empty if prompt on deploy is set') if (self.prompt? && !self.value.blank?)
    self.errors.add('name', 'can\'t contain a colon') if (!self.name.blank? && self.name.strip.starts_with?(":"))
  end
  
  def prompt?
    self.prompt_on_deploy == 1
  end
  
  def empty_value_if_deploy_is_set
    self.value = nil if self.prompt?
  end
  
  def prompt_status_in_html
    if self.prompt?
      "<span class='configuration_prompt'>prompt</span>"
    else
      ''
    end
  end
end
