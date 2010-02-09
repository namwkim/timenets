class HomeController < ApplicationController
  def intro #login and signup
    if (@operator!=nil)
      redirect_to(:action => "index")
    else
      @user = flash[:user] if flash[:user] 
      @profile = flash[:profile] if flash[:profile] 
      render :layout => false
    end
  end
  def index
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
      @profile = Profile.new(params[:profile]) 
      @user.profile = @profile
      if @user.save and @profile.save
        session[:operator_id] = @user.id        
        #create an initial project associated with the new user
        @project = Project.create(:name=>@profile.first_name+"'s genealogy project", :description=>"Describe your genealogy project here!")
        ManagedProject.create(:user_id=>@user.id, :project_id=>@project.id, :privilege=>"Editor")
        @project.profiles << @profile
        redirect_to(:action => "index")
      else
        flash[:user] = @user
        flash[:profie] = @profile
        redirect_to(:action => "intro")
      end
    else
      redirect_to(:action => "intro")
    end
  end

end
