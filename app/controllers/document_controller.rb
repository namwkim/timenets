class DocumentController < ApplicationController
  before_filter :change_data_type, :only=>[:create_document, :update_document, :create_document_in_event, :update_document_in_event]
  
  def new_document
    @document = Document.new
    @action   = "create_document"
    @project_id = params[:project_id]
    render :action=>"new_document", :layout => false
  end

  def create_document
    @document = build_document params
    @document.project = Project.find_by_id(params[:project_id])
    if @document.save
      #flash[:notice] = 'Document was successfully added.'
      log "created", @document, @document.project      
      respond_to do |format|
        format.html {redirect_to(:action=>"index")}
        format.js   { 
          responds_to_parent do
            render :partial => "add_document", :locals=>{:document=>@document}
          end
        }
      end
    else      
      render :action =>"new_document"
    end
  end
  def edit_document
    @document = Document.find_by_id(params[:id])
    @action   = "update_document"
    render :layout=>false
  end

  def update_document
    @document = Document.find_by_id(params[:id])
    if update_document_attributes @document, params
      log "updated", @document, @document.project
      responds_to_parent do render :partial => "update_document", :locals=>{:document=>@document} end
    else
      render :action=>"edit_document"
    end
  end
  def delete_document
    @document = Document.find_by_id(params[:id])
    #delete file if exists
    Document.delete_file(@document.file_url)
    Document.destroy(@document)  
    log "deleted", @document, @document.project
    render :nothing=>true
  end
  def show_document
    @document = Document.find_by_id(params[:id])
    render :layout=>false
  end
  def auto_complete_for_document_name
    query = params[:doc_name]
    query = "%#{query}%"
    @documents = Document.find(
      :all,
      :conditions => ['project_id=? and LOWER(name) LIKE ?', params[:project_id], query],
      :limit => 10
    )
    render :partial => 'document_completions'
  end  
  ############################## Event ##############################
  def new_document_in_event
    @document = Document.new
    @action   = "create_document_in_event"
    @project_id = params[:project_id]
    @event_id   = params[:event_id]
    render :action=>"new_document", :layout => false    
  end
  def create_document_in_event
    @document = build_document params
    @document.project = Project.find_by_id(params[:project_id])
    if @document.save
      if params[:event_id].nil? 
        session[:documents] << @document.id
        @event = nil
      else
        @event = Event.find_by_id(params[:event_id])
        @event.documents << @document
        log "added, in event,", @document, @document.project
      end
      log "created", @document, @document.project
      respond_to_parent do 
        render :partial=>"add_document_in_event", :locals=>{:document=>@document, :event=>@event}
      end
    else
      render :action=>"new_document_in_event"
    end 
  end  
    def edit_document_in_event
    @document = Document.find_by_id(params[:id])
    @action   = "update_document_in_event"
    @event_id = params[:event_id]
    render :action=>"edit_document", :layout=>false
  end
  def update_document_in_event
     @document = Document.find_by_id(params[:id])
    if update_document_attributes @document, params
      @event = Event.find_by_id(params[:event_id]) if params[:event_id]!=nil
      log "updated", @document, @document.project
      responds_to_parent do 
        render :partial => "update_document_in_event", :locals=>{:document=>@document, :event=>@event}
      end 
    else
      render :action=>"edit_document_in_event"
    end
  end
  def delete_document_in_event
    @document = Document.find_by_id(params[:id])
    if params[:event_id]!=nil
      @event  = Event.find_by_id(params[:event_id])       
      @event.documents.delete(@document)
      log "removed, in event,", @document, @document.project
    else
      session[:documents].delete(@document.id)
    end
    render :nothing=>true
  end
  def add_document_in_event
    @document = Document.find_by_id(params[:doc_id])
    if params[:event_id]!=nil
      @event = Event.find_by_id(params[:event_id])
      @event.documents << @document
      log "added, in event,", @document, @document.project
    else
      session[:documents] << @document.id
    end
    render :partial=>"add_document_in_event", :locals=>{:document=>@document, :event=>@event}
  end
private
  def change_data_type
    if params[:html_format]==nil or params[:html_format]!="true"
      request.format = :js if is_amf!=true
    end    
  end  
  def build_document params
    if (params[:document][:file_url] != nil)
      params[:document][:file_url] = Document.upload_file(@operator, params[:document][:file_url])
    end
    Document.new(params[:document])     
  end
  def update_document_attributes document, params
    if (params[:document][:file_url] != nil)
      params[:document][:file_url] = Document.upload_file(@operator, params[:document][:file_url])
      Document.delete_file(document.file_url)
    end
    document.update_attributes(params[:document])
  end
end