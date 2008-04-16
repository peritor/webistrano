module RecipesHelper
  def highlight_syntax(code)
    Syntax::Convertors::HTML.for_syntax("ruby").convert(code)
  end
end
