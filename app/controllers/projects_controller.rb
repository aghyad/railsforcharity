class ProjectsController < ApplicationController
  before_filter :find_project, :only => [:show, :edit, :update, :destroy, :settings, :vote, :join, :unjoin]
  before_filter :authenticate_user!, :except => [:show, :index]

  def index
    @projects = Project.find_with_reputation(:votes, :all, order: 'votes desc', :include => [:creator, :avatar, :users])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @tasks = @project.tasks.includes([:creator])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.json
  def new
    @project = Project.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(params[:project])
    @project.creator = current_user

    respond_to do |format|
      if @project.save
        format.html { redirect_to project_path(@project), notice: t('controllers.projects.create.success') }
        format.json { render json: @project, status: :created, location: @project }
      else
        format.html { render action: "new" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update_attributes(params[:project])
        format.html { redirect_to @project, notice: t('controllers.projects.update.success') }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy

    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end
  end

  def settings
  end

  def vote
    value = params[:type] == "up" ? 1 : -1
    @project.add_or_update_evaluation(:votes, value, current_user)
    redirect_to :back, notice: "Thank you for voting!"
  end

  def join
    if @project.make_collaborator(current_user)
      properties = EmailTemplate::TYPES.reduce({}) { |accumulator, property| accumulator.merge(property.first.to_s => "1") }
      Preference.find_or_create_by_user_id_and_entity_type_and_entity_id(current_user.id, 'Project', @project.id, {
        properties: properties
      })

      redirect_to :back, notice: "Thank you for joining #{@project.name}!, Happy collaborating !!!"
    else
      redirect_to :back, notice: "Failed to join the project #{@project.name}, please try again later!"
    end

  end

  def unjoin
    if @project.user_permissions_obj(current_user).destroy
      redirect_to :back, notice: "You are successfully removed from the collaborator list!"
    else
      redirect_to :back, notice: "Aww Snap! Failed to unjoin, please try again later!"
    end
  end

  private

  def find_project
    @project = Project.find(params[:id])
  end

end
