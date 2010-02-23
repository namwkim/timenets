class UserController < ApplicationController
  def show_collaborators
    @project = Project.find_by_id(params[:project_id])
    @collaborators = @project.users.paginate :page=>params[:page], :per_page=>15, :order=>"email"
  end  
end
