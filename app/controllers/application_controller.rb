# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :authenticate, :except => [:login, :intro, :signup]
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  layout :determine_layout
  
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  
  def determine_layout
    'familystory'
  end
protected
 
  def authenticate
    session[:original_uri] = request.request_uri
    @operator = User.find_by_id(session[:operator_id])
    if @operator == nil
      redirect_to :controller=>'home', :action=>'intro'
    end
  end

end
