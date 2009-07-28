# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def nice_flash(text)
    render(:partial => 'layouts/flash', :locals => {:text => text})
  end

  def error_flash(text)
    render(:partial => 'layouts/flash_error', :locals => {:text => text})
  end
  
  def locking_flash(text)
    render(:partial => 'layouts/flash_locking', :locals => {:text => text})
  end
  
  def flashed_errors(object_name)
    obj = instance_variable_get("@#{object_name}")
    return nil if obj.errors.blank?
    
      
    error_messages = obj.errors.full_messages.map {|msg| content_tag(:li, msg)}

    html = content_tag(:p,"#{pluralize(obj.errors.size, 'error')} prohibited this #{object_name.to_s.gsub('_', ' ')} from being saved")
    html << content_tag(:div,
                       content_tag(:ul, error_messages)
                       )
    
    content_for(:flash_content) do                   
      error_flash(html)
    end
  end
  
  def web_friendly_text(text)
    return text if text.blank?
    h(text).gsub("\n",'<br />').gsub("\r",'')
  end
  
  def hide_password_in_value(config)
    if !config.prompt? && config.name.match(/password/) 
      '************'
    else
      config.value
    end
  end
  
  def current_stage_project_description
    "stage: #{link_to h(current_stage.name), project_stage_path(current_project, current_stage)} (of project #{link_to h(current_project.name), project_path(current_project)})"
  end
  
  # returns the open/closed status of a menu
  # either the active controller is used or the given status is returned
  def controller_in_use_or(contr_name, status, klass)
    if @controller.is_a? contr_name
      :open
    else
      if status == :closed && (klass.count <= 3 )
        # the box should be closed
        # open it anyway if we have less than three
        status = :open
      end
  
      status
    end
  end
  
  # returns the display:none/visible attribute
  # if the stages of a project should be shown
  def show_stages_of_project(project)
    a_stage_active = false
    
    # check each stage
    project.stages.each do |stage|
      a_stage_active = true unless active_link_class(stage).blank?
    end
    
    # check project
    a_stage_active = true unless active_link_class(project).blank?
    
    a_stage_active ? '' : 'display:none;'
  end
  
  # negation of show_stages_of_project(project)
  def do_not_show_stages_of_project(project)
    if show_stages_of_project(project).blank?
      'display:none;'
    else
      ''
    end
  end
  
  def user_info(user)
    link_to user.login, user_path(user)
  end
  
  def show_if_closed(status)
    status != :closed ?  'display:none;' : ''
  end
  
  def show_if_opened(status)
    status != :open ?  'display:none;' : ''
  end
  
  # returns a CSS class if the current item is an active item
  def active_link_class(item)
    active_class = 'active_menu_link'
    found = false
    case item.class.to_s
    when 'Project'
      found = true if (@project && @project == item) && (@stage.blank?)
    when 'Host'
      found = true if @host && @host == item
    when 'Recipe'
      found = true if @recipe && @recipe == item
    when 'User'
      found = true if @user && @user == item
    when 'Stage'
      found = true if @stage && @stage == item
    end
    
    if found
      active_class
    else
      ''
    end
  end
  
  def breadcrumb_box(&block)
    out = "<div class='breadcrumb'><b>"
    out << capture(&block) if block
    out << "</b></div>"
    
    block ? concat(out) : out
  end
  
end
