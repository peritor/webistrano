module RecipesHelper
  def highlight_syntax(code)
    Syntax::Convertors::HTML.for_syntax("ruby").convert(code)
  end
  
  def all_recipe_versions
    versions = @recipe.versions.collect{|v| ["Version #{v.version}", v.version.to_s]}.reverse
    versions[0] = ["Latest version", ""]
    versions
  end
  
  def not_latest_version
    !params[:version].blank? && params[:version].to_i < @recipe.versions.latest.version
  end
end
