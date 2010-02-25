class ProjectController < ApplicationController
  def index
    @user = @operator
  end
  def show_project_list
    @user = User.find_by_id(params[:id])
    render :action=>"index"
  end
  def show_project
    @project = Project.find_by_id(params[:id])
    @root  = @operator.person #select it more elegantly
  end
  def new_project
    @project = Project.new
    respond_to do |format|
      format.js { render :layout=>false}
    end
  end
  def create_project
    @project = Project.new(params[:project])
    @operator.projects << @project
    if @project.save
      flash[:notice] = 'Project was successfully added.'
      respond_to do |format|
        format.js { render :partial => "add_project", :locals=>{:project=>@project}}
      end      
    else      
      rende
    end
  end
  def edit_project
    @project = Project.find_by_id(params[:id])
    respond_to do |format|
      format.js { render :layout=>false}
    end
  end
  def update_project
    @project = Project.find_by_id(params[:id])
    if @project.update_attributes(params[:project])
      respond_to do |format|
        format.js { render :partial => "update_project", :locals=>{:project=>@project} }
      end
      
    else
      render :action=>"edit_project"
    end
  end
  def delete_project
    @project = Project.find_by_id(params[:id])
    @project.destroy
  end
  def set_main_project
    @operator.main_project = Project.find_by_id(params[:id])
    @operator.save
    render :nothing=>true
  end
  def people
    @project = Project.find_by_id(params[:id])
    if (params[:search_person]==nil)
      @people = @project.people.paginate :page=>params[:page], :per_page=>5, :order=>"last_name"
    else
      query = "%#{params[:search_person]}%"
      @people = Person.find(:all, :conditions=>['project_id=? and (LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ?)', @project.id, query, query])
      @people = @people.paginate :page=>params[:page], :per_page=>5, :order=>"last_name"
    end    
    render :partial=>"people", :locals=>{:project=>@project, :people=>@people}     
  end
  def events
    @project = Project.find_by_id(params[:id])
    if (params[:search_event]==nil)
      @events = @project.events.paginate :page=>params[:page], :per_page=>5, :order=>"name"
    else
      query = "%#{params[:search_event]}%"
      @events = Event.find(:all, :conditions=>['project_id=? and (LOWER(name) LIKE ?)', @project.id, query])
      @events = @events.paginate :page=>params[:page], :per_page=>5, :order=>"name"
    end    
    render :partial=>"events", :locals=>{:project=>@project, :events=>@events}
  end
  def documents
    @project = Project.find_by_id(params[:id]) 
    if (params[:search_document]==nil)
      @documents = @project.documents.paginate :page=>params[:page], :per_page=>5, :order=>"name"
    else
      query = "%#{params[:search_document]}%"
      @documents = Event.find(:all, :conditions=>['project_id=? and (LOWER(name) LIKE ?)', @project.id, query])
      @documents = @documents.paginate :page=>params[:page], :per_page=>5, :order=>"name"
    end   
    render :partial=>"documents", :locals=>{:project=>@project, :documents=>@documents}
  end
end
