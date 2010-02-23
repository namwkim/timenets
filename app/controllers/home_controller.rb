class HomeController < ApplicationController
  def intro #login and signup
    if (@operator!=nil)
      redirect_to(:action => "index")
    else
      @user = flash[:user] if flash[:user] 
      @person = flash[:person] if flash[:person] 
      render :layout => false
    end
  end
  def index
    redirect_to(:controller=>"project", :action=>"show_project", :id=>@operator.main_project.id)
  end
  def login
    if request.post?
      user = User.authenticate(params[:email], params[:password])
      if user
        session[:operator_id] = user.id
        redirect_to(:action => "index")
      else
        flash[:notice] = "Invalid user/password combination"
        redirect_to(:action => "intro")
      end
    else
      redirect_to(:action => "intro")
    end
  end
  def logout
    if (@operator!=nil)
      @operator = nil
      session[:operator_id] = nil
    end
    redirect_to(:action => "intro")   
  end
  def signup
    if request.post?
      @user    = User.new(params[:user])
      @person = Person.new(params[:person]) 
      @user.person = @person
      if @user.save and @person.save
        session[:operator_id] = @user.id        
        #create an initial project associated with the new user
        @project = Project.create(:name=>"The"+@person.last_name+" Family", :description=>"Describe your genealogy project here!")
        @user.managed_projects.create( :project_id=>@project.id, :privilege=>"Editor")
        @project.people << @person
        @user.main_project = @project
        @user.save
        redirect_to(:action => "index")
      else
        flash[:user] = @user
        flash[:profie] = @person
        redirect_to(:action => "intro")
      end
    else
      redirect_to(:action => "intro")
    end
  end

end
