class ActivityController < ApplicationController
  def show_all
    @project = Project.find_by_id(params[:project_id])
    @activities = @project.activities.paginate :page=>params[:page], :per_page=>10, :order=>"created_at DESC"
  end
end
