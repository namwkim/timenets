class HomeController < ApplicationController
  def intro #login and signup
    if (@operator!=nil)
      redirect_to(:action => "index")
    else
      @user = flash[:user] if flash[:user] 
      @person = flash[:person] if flash[:person] 
      if (params[:token]!=nil)
        @invitation_token = params[:token]
        @invitation       = Invitation.find_by_token(@invitation_token)
        @email            = @invitation.recipient_email
      else
        @invitation_token = @invitation = @email = nil
      end        
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
        
        if params[:login_invitation_token]!=''
          @invitation = Invitation.find_by_token(params[:login_invitation_token])
          if @invitation.accepted 
            flash[:notice] = "This invitation was used already."
            redirect_to(:action => "intro") and return
          end
          @project    = @invitation.project
          if user.projects.include?(@project) == false
            user.managed_projects.create( :project_id=>@project.id, :privilege=>"Editor")  
            user.save
            @operator = User.find_by_id user.id
            log "joined", @project, @project
            @invitation.update_attribute(:accepted, true);
            session[:operator_id] = user.id
            log "logged in", nil, nil
            redirect_to(:controller=>"project", :action=>"show_project", :id=>@project.id) and return
          end
        end        
        session[:operator_id] = user.id
        log "logged in", nil, nil
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
    flash[:notice]=""
    if (@operator!=nil)
      @operator = nil
      log "logged out", nil, nil
      session[:operator_id] = nil
    end
    #flash[:notice]=""
    redirect_to(:action => "intro")   
  end
  def signup
    if request.post?
      @user    = User.new(params[:user])
      @person = Person.new(params[:person]) 
      @user.person = @person
      if @user.save and @person.save            
        if params[:signup_invitation_token]==''
          @project = Project.create(:name=>"The "+@person.last_name+" Family", :description=>"Describe your genealogy project here!")
        else
          @invitation = Invitation.find_by_token(params[:signup_invitation_token])
          if @invitation.accepted 
            flash[:notice] = "This invitation was used already."
            redirect_to(:action => "intro")
          end
          @project    = @invitation.project
          @invitation.update_attribute(:accepted, true);
        end
        @project.people << @person
        @user.managed_projects.create( :project_id=>@project.id, :privilege=>"Editor") 
        @user.main_project = @project 
        @user.save
        @operator = User.find_by_id @user.id
        log "signed up for Akinu", nil, nil
        log "joined", @project, @project
        session[:operator_id] = @user.id 
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
