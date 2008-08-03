module ProjectsHelper
  
  def clone_form_path(project)
    "#{new_project_path}?clone=#{project.id}"
  end
  
  def clone_path(project)
    "#{projects_path}?clone=#{project.id}"
  end
  
end
