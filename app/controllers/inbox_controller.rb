class InboxController < ApplicationController
  def new_message    
    @to_id = params[:id]
    render :layout=>false
  end
  def send_message
    @collaborator = User.find_by_id(params[:to_id])
    KinMailer.deliver_message_to_collaborator @operator, @collaborator, params[:subject], params[:body]
    render :nothing=>true
  end
end
