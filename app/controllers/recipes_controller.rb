class RecipesController < ApplicationController
  before_filter :ensure_can_manage_recipes, :except => [:show, :index]
  
  # GET /recipes
  # GET /recipes.xml
  def index
    @recipes = Recipe.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @recipes.to_xml }
    end
  end

  # GET /recipes/1
  # GET /recipes/1.xml
  def show
    find_recipe_with_version
    
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @recipe.to_xml }
    end
  end

  # GET /recipes/new
  def new
    @recipe = Recipe.new
  end

  # GET /recipes/1;edit
  def edit
    find_recipe_with_version
  end

  # POST /recipes
  # POST /recipes.xml
  def create
    @recipe = Recipe.new((params[:recipe] || {}).merge(:user_id => current_user.id))

    respond_to do |format|
      if @recipe.save
        flash[:notice] = 'Recipe was successfully created.'
        format.html { redirect_to recipe_url(@recipe) }
        format.xml  { head :created, :location => recipe_url(@recipe) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @recipe.errors.to_xml }
      end
    end
  end

  # PUT /recipes/1
  # PUT /recipes/1.xml
  def update
    @recipe = Recipe.find(params[:id])

    respond_to do |format|
      if @recipe.update_attributes((params[:recipe] || {}).merge(:user_id => current_user.id))
        flash[:notice] = 'Recipe was successfully updated.'
        format.html { redirect_to recipe_url(@recipe) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @recipe.errors.to_xml }
      end
    end
  end

  # DELETE /recipes/1
  # DELETE /recipes/1.xml
  def destroy
    @recipe = Recipe.find(params[:id])
    @recipe.destroy
    flash[:notice] = 'Recipe was successfully deleted.'
    
    respond_to do |format|
      format.html { redirect_to recipes_url }
      format.xml  { head :ok }
    end
  end
  
  def preview
    @recipe = Recipe.new(params[:recipe])

    render "recipes/_preview", :locals => {:recipe => @recipe}, :layout => false
  end
  
  private
  def find_recipe_with_version
    @recipe = Recipe.find(params[:id])
    
    unless params[:version].blank?
      recipe_version = @recipe.find_version(params[:version])
      @recipe.attributes = @recipe.find_version(params[:version]).attributes if recipe_version
    end
  end
end
