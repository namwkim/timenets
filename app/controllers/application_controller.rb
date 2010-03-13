# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  #before_filter :authenticate, :except => [:login, :intro, :signup, :root, :create_relationship, :create_person, :update_person, :update_marraige, :delete_person, :delete_relationship, :update_marriage] 
  before_filter :establish_operator
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  layout :determine_layout
  
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  
  def determine_layout
    'akinu'
  end
protected
  def establish_operator
    @operator = User.find_by_id(session[:operator_id]) if @operator == nil
  end
  def authenticate
    if params[:session_id]!=nil
      
    end
    session[:original_uri] = request.request_uri
    @operator = User.find_by_id(session[:operator_id])
    if @operator == nil
      respond_to do |format|
        format.html { redirect_to :controller=>'home', :action=>'intro' }        
      end
    end
  end
  def log action_verb, record, project
    #time = Time.now.strftime("%B %d at %H:%M%p")
    if @operator.nil?
      @operator = User.find_by_id(session[:operator_id])
      return if @operator.nil?
    end
    html_text = (@operator.person.name==nil ? "": @operator.person.name)+" "+action_verb+" "
    html_text = html_text + record.name if record!=nil    
    activity = Activity.create(:html=>html_text)
    project.activities<<activity if project!=nil
    @operator.activities<<activity
    @operator.save
    project.save if project!=nil
  end  
end
