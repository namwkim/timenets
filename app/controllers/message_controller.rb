class MessageController < ApplicationController
  def new_message
    @to_id = params[:id]
    render :layout=>false
  end
  def send_message
    collaborator = User.find_by_id(params[:to_id])
    KinMailer.deliver_message_to_collaborator(@operator, collaborator, params[:subject], params[:body])
    render :partial=>"alert", :locals=>{:msg=>"Message sent!"}
  end
  def new_invitation
    @invitation = Invitation.new
    @project = Project.find_by_id(params[:project_id])
    render :layout=>false
  end
  def send_invitation
    @invitation = Invitation.new(params[:invitation])
    @project    = Project.find_by_id(params[:project_id])
    @invitation.sender  = @operator
    @invitation.project = @project
    #create url
    if @invitation.save
      KinMailer.deliver_invitation(@invitation, intro_url(@invitation.token))   
      render :partial=>"alert", :locals=>{:msg=>"Thank you, Invitation sent!"}
    else
      render :partial=>"alert", :locals=>{:msg=>"Invitation NOT sent! Something went wrong..."}
    end
  end
  
end
