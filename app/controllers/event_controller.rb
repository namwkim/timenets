class EventController < ApplicationController
  def new_event
    @event = Event.new
    @project = Project.find_by_id(params[:project_id])
    session[:documents] = Array.new
    session[:people]  = Array.new
  end
  def create_event
    @event = Event.new(params[:event])
    #link with documents uploaded
    save_attachments_in_event @event
    @event.project = Project.find_by_id(params[:project_id])
    if @event.save
      log "created", @event, @event.project
      flash[:notice] = 'Event was successfully added.'
      redirect_to(:controller=>"project", :action =>"show_project", :id=>@event.project.id) 
    else      
      render :action =>"new_event"
    end
  end
  def edit_event
    @event = Event.find_by_id(params[:id])
    @project = Project.find_by_id(params[:project_id])
    session[:documents] = Array.new    
    session[:people]  = Array.new
  end
  def update_event
    @event = Event.find_by_id(params[:id])
    save_attachments_in_event @event
    if @event.update_attributes(params[:event])
      log "updated", @event, @event.project
      flash[:notice] = 'Event was successfully updated.'
      redirect_to(:controller=>"project", :action =>"show_project", :id=>@event.project.id) 
    else
      render :action=>"edit_event"
    end
  end
  def delete_event
    @event = Event.find_by_id(params[:id])
#    #delete related documents 
#    @event.documents.each do |doc|
#      Document.delete_file(doc.file_url)
#      Document.destroy(doc)
#    end
    @event.destory
    log "deleted", @event, @event.project
    render :nothing=>true
  end
  def show_event
    @event = Event.find_by_id(params[:id])
    @project = @event.project
  end  


private
  def save_attachments_in_event event
    session[:documents].each do |doc_id|
      doc = Document.find_by_id(doc_id);
      event.documents <<  doc unless event.documents.include?(doc)
      log "added, in event,", doc, doc.project
    end
    session[:people].each do |person_id|
      person = Person.find_by_id(person_id)
      event.people << person unless event.people.include?(person)
      log "added, in event,", person, person.project
    end
    session[:documents] = nil
    session[:people]  = nil
  end
end
