# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  #before_filter :authenticate, :except => [:login, :intro, :signup, :root, :create_relationship, :update_person] 
  before_filter :authorize
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  layout :determine_layout
  
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  
  def determine_layout
    'akinu'
  end
protected
  def authorize
    @operator = User.find_by_id(session[:operator_id]) if @operator == nil
  end
  def authenticate
    session[:original_uri] = request.request_uri
    @operator = User.find_by_id(session[:operator_id])
    if @operator == nil
      respond_to do |format|
        format.html { redirect_to :controller=>'home', :action=>'intro' }        
      end
    end
  end
  def log action_verb, record, project
#    #time = Time.now.strftime("%B %d at %H:%M%p")
#    html_text = @operator.person.name+" "+action_verb+" "+record.name#+" in "+project.name + ", "+time
#    activity = Activity.create(:html=>html_text)
#    project.activities<<activity
#    @operator.activities<<activity
#    @operator.save
#    project.save
  end  
end
