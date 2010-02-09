class ProfileController < ApplicationController
  require 'lightbox_helper'
  before_filter :change_data_type, :only=>[:create_document, :create_profile, :create_profile_in_event, :create_document_in_event,
    :update_document, :update_profile, :update_profile_in_event, :update_document_in_event]
  def index
    @profile = @operator.profile
  end
  def new_profile
    @profile = Profile.new
    @action = "create_profile"
    @project_id = params[:project_id]
    respond_to do |format|
      format.html {}
      format.js { render :layout=>false }
    end
  end
  def new_profile_in_event
    @profile = Profile.new
    @action = "create_profile_in_event"
    @project_id = params[:project_id]
    @event_id   = params[:event_id]
    render :action=>"new_profile", :layout=>false
  end
  def create_profile      
    @profile = build_profile params
    @profile.project = Project.find_by_id(params[:project_id])
    if @profile.save      
      log "created", "Profile", @profile.id, @profile.project.id
      respond_to do |format|
        format.html {redirect_to(:action=>"index")}
        format.js { 
          responds_to_parent do 
            render :partial=>"add_profile", :locals=>{:profile=>@profile}
          end
        }    
      end
    else
        render :action=>"new_profile"
    end
  end
  def create_profile_in_event
    @profile = build_profile params
    @profile.project = Project.find_by_id(params[:project_id])
    if @profile.save      
      if params[:event_id].nil? 
        session[:profiles] << @profile.id
      else
        @event = Event.find_by_id(params[:event_id])
      end      
      responds_to_parent do 
        render :partial=>"add_profile_in_event", :locals=>{:profile=>@profile, :event=>@event}  
      end
    else
      render :action=>"new_profile_in_event"
    end
  end
  def edit_profile
    @profile  = Profile.find_by_id(params[:id])
    @action   = "update_profile"
    respond_to do |format|
      format.html{  @html_format = true }
      format.js{ render :layout=>false}
    end
  end
  def edit_profile_in_event
    @profile = Profile.find_by_id(params[:id])
    @action  = "update_profile_in_event"
    render :action=>"edit_profile", :layout=>false
  end
  def update_profile
    @profile = Profile.find_by_id(params[:id])
    if update_profile_attributes @profile, params
      respond_to do |format|
        format.html {redirect_to(:action=>"index")}
        format.js { 
          responds_to_parent do 
            render :partial=>"update_profile", :locals=>{:profile=>@profile}
          end
        }
      end
    else
      render :action=>"edit_profile"
    end
  end
  def update_profile_in_event
    @profile = Profile.find_by_id(params[:id])
    if update_profile_attributes @profile, params
      responds_to_parent do
        render :partial=>"update_profile_in_event", :locals=>{:profile=>@profile}
      end      
    else
      render :action=>"edit_profile_in_event"
    end
  end
  def show_profile
    @profile = Profile.find_by_id(params[:id])
    render :action=>"index"
  end
  def delete_profile
    @profile = Profile.find_by_id(params[:id])
    Profile.delete_file(@profile.photo_url)
    Profile.destroy(@profile)
    render :nothing=>true
  end
  ############################## Relationship ##############################
  def new_relationship
    @profile  = Profile.new
    @ref_id   = params[:ref_id]
    @role_id  = params[:role_id]
    render :layout=>false
  end
  def create_relationship
    if params[:profile_id]!=nil
      @profile = Profile.find_by_id(params[:profile_id])
    else
      @profile = Profile.new(params[:profile])
    end
    @ref_profile = Profile.find_by_id(params[:ref_id])
    @profile.project = @ref_profile.project # inherit project
    if @profile.save and params[:ref_id]!=nil and params[:role_id]!=nil
      #build relationship      
      @rel     = Relationship.new
      @ref_rel = Relationship.new      
      @rel.profile_id     = @ref_rel.family_member_id = @profile.id
      @ref_rel.profile_id = @rel.family_member_id     = @ref_profile.id
      role = Role.find_by_id(params[:role_id])
      case role.name
        when "Father", "Mother"
          @rel.type_id     = RelationshipType.find_by_name("Parent-Child").id
          @ref_rel.type_id = RelationshipType.find_by_name("Parent-Child").id
          @rel.profile_role_id       = role.id
          @rel.family_member_role_id = Role.find_by_name("Child").id
          @ref_rel.profile_role_id       = Role.find_by_name("Child").id
          @ref_rel.family_member_role_id = role.id
        when "Child"
          @rel.type_id     = RelationshipType.find_by_name("Parent-Child").id
          @ref_rel.type_id = RelationshipType.find_by_name("Parent-Child").id
          @rel.profile_role_id       = role.id
          @rel.family_member_role_id = Role.find_by_name(@ref_profile.sex=="Male"? "Father":"Mother").id
          @ref_rel.profile_role_id       = Role.find_by_name(@ref_profile.sex=="Male"? "Father":"Mother").id
          @ref_rel.family_member_role_id = role.id
        when "Spouse"
          @rel.type_id     = RelationshipType.find_by_name("Marriage").id
          @ref_rel.type_id = RelationshipType.find_by_name("Marriage") .id  
          @rel.profile_role_id       = role.id
          @rel.family_member_role_id = role.id
          @ref_rel.profile_role_id       = role.id
          @ref_rel.family_member_role_id = role.id
          divorced = params[:relationship][:divorced]
          params[:relationship].delete(:divorced)
          @rel.update_attributes(params[:relationship])
          @ref_rel.update_attributes(params[:relationship])
          @rel.update_attribute("end_date", nil) if divorced!="true"
          @ref_rel.update_attribute("end_date",nil ) if divorced!="true" 
      end
    end
    if @ref_profile.save and @rel.save and @ref_rel.save
      flash[:notice] = 'Profile was successfully added.'
      respond_to do |format|
        format.html {}
        format.js { render :partial => "add_relationship", :locals=>{:profile=>@profile, :role=>role.name, :rel=>@rel} }
      end
    else      
      render :action =>"new_relationship"
    end
  end
  def delete_relationship    
    @rel = Relationship.find_by_id(params[:id])
    @conj_rel = @rel.conjugate
    @rel.destroy
    @conj_rel.destroy
    render :nothing=>true
  end
  def edit_relationships
    @profile =  Profile.find_by_id(params[:id])
  end
  def auto_complete_for_profile_name
    query = params[:profile_name]
    query = "%#{query}%"
    @profiles = Profile.find(
      :all,
      :conditions => ['project_id=? and (LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ?)', params[:project_id], query, query],
      :limit => 10
    )
    render :partial => 'profile_completions'
  end
  ############################## Event ##############################
  def new_event
    @event = Event.new
    @project = Project.find_by_id(params[:project_id])
    session[:documents] = Array.new
    session[:profiles]  = Array.new
  end
  def create_event
    @event = Event.new(params[:event])
    #link with documents uploaded
    save_attachments_in_event @event
    @event.project = Project.find_by_id(params[:project_id])
    if @event.save
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
    session[:profiles]  = Array.new
  end
  def update_event
    @event = Event.find_by_id(params[:id])
    save_attachments_in_event @event
    if @event.update_attributes(params[:event])
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
    Event.destroy(@event)
    render :nothing=>true
  end
  def show_event
    @event = Event.find_by_id(params[:id])
    @project = @event.project
  end  
  def delete_profile_in_event
    @profile = Profile.find_by_id(params[:id])
    if params[:evt_id]!=nil
      @event  = Event.find_by_id(params[:id])      
      @event.profiles.delete(@profile.id)
    else
      session[:profiles].delete(@profile.id)
    end
    render :nothing=>true
  end
  def add_profile_in_event
    @profile = Profile.find_by_id(params[:profile_id])
    if params[:event_id]!=nil
      @event = Event.find_by_id([params[:event_id]])
      @event.profiles << @profile
    else
      session[:profiles] << @profile.id
    end    
    render :partial=>"add_profile_in_event", :locals=>{:profile=>@profile, :event=>@event}
  end
  ############################## Document ########################################
  def new_document
    @document = Document.new
    @action   = "create_document"
    @project_id = params[:project_id]
    render :action=>"new_document", :layout => false
  end
  def new_document_in_event
    @document = Document.new
    @action   = "create_document_in_event"
    @project_id = params[:project_id]
    @event_id   = params[:event_id]
    render :action=>"new_document", :layout => false    
  end
  def create_document
    @document = build_document params
    @document.project = Project.find_by_id(params[:project_id])
    if @document.save
      #flash[:notice] = 'Document was successfully added.'      
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
  def create_document_in_event
    @document = build_document params
    @document.project = Project.find_by_id(params[:project_id])
    if @document.save
      if params[:event_id].nil? 
        session[:documents] << @document.id
      else
        @event = Event.find_by_id(params[:event_id])
      end
      respond_to_parent do 
        render :partial=>"add_document_in_event", :locals=>{:document=>@document, :event=>@event}
      end
    else
      render :action=>"new_document_in_event"
    end 
  end  
  def edit_document
    @document = Document.find_by_id(params[:id])
    @action   = "update_document"
    render :layout=>false
  end
  def edit_document_in_event
    @document = Document.find_by_id(params[:id])
    @action   = "update_document_in_event"
    render :action=>"edit_document", :layout=>false
  end
  def update_document
    @document = Document.find_by_id(params[:id])
    if update_document_attributes @document, params
      render :partial => "update_document_in_event", :locals=>{:document=>@document}
    else
      render :action=>"edit_document_in_event"
    end
  end
  def update_document_in_event
     @document = Document.find_by_id(params[:id])
    if update_document_attributes @document, params
      if params[:event_id]!=nil
        @event = Event.find_by_id(params[:event_id]) 
        @event.documents << @document
      end
      responds_to_parent do 
        render :partial => "update_document_in_event", :locals=>{:document=>@document, :event=>@event}
      end 
    else
      render :action=>"edit_document_in_event"
    end
  end
  def delete_document
    @document = Document.find_by_id(params[:id])
    #delete file if exists
    Document.delete_file(@document.file_url)
    Document.destroy(@document)
    render :nothing=>true
  end
  def show_document
    @document = Document.find_by_id(params[:id])
    render :layout=>false
  end
  def auto_complete_for_document_title
    query = params[:doc_name]
    query = "%#{query}%"
    @documents = Document.find(
      :all,
      :conditions => ['project_id=? and LOWER(title) LIKE ?', params[:project_id], query],
      :limit => 10
    )
    render :partial => 'document_completions'
  end  
  def delete_document_in_event
    if params[:event_id]!=nil
      @event  = Event.find_by_id(params[:event_id])
      @document = Document.find_by_id(params[:id])
      @event.documents.delete(@document.id)
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
    else
      session[:documents] << @document.id
    end
    render :partial=>"add_document_in_event", :locals=>{:document=>@document}
  end
private
  def change_data_type
    if params[:html_format]==nil or params[:html_format]!="true"
      request.format = :js
    end    
  end
  def build_profile params
    if (params[:profile][:photo_url] != nil)
      params[:profile][:photo_url] = Profile.upload_file(@operator, params[:profile][:photo_url])
    end
    Profile.new(params[:profile])
  end
  def build_document params
    if (params[:document][:file_url] != nil)
      params[:document][:file_url] = Document.upload_file(@operator, params[:document][:file_url])
    end
    Document.new(params[:document])     
  end
  def update_profile_attributes profile, params    
    if (params[:profile][:photo_url] != nil)
      params[:profile][:photo_url] = Profile.upload_file(@operator, params[:profile][:photo_url])
      Profile.delete_file(profile.photo_url)
    end
    profile.update_attributes(params[:profile])
  end
  def update_document_attributes document, params
    if (params[:document][:file_url] != nil)
      params[:document][:file_url] = Document.upload_file(@operator, params[:document][:file_url])
      Document.delete_file(document.file_url)
    end
    document.update_attributes(params[:document])
  end
  def save_attachments_in_event event
    session[:documents].each do |doc_id|
      doc = Document.find_by_id(doc_id);
      event.documents <<  doc unless event.documents.include?(doc)
    end
    session[:profiles].each do |prof_id|
      prof = Profile.find_by_id(prof_id)
      event.profiles << prof unless event.profiles.include?(prof)
    end
    session[:documents] = nil
    session[:profiles]  = nil
  end
  def log action_verb, record_type, record_id, project_id
    project = Project.find_by_id(project_id)
    case record_type
      when "Profile"
        record = Profile.find_by_id(record_id)
      when "Event"
        record = Event.find_by_id(record_id)
      when "Document"
        record = Document.find_by_id(record_id)
    end
    html_text = @operator.profile.name+" "+action_verb+" "+record.name+" in "+project.name
    @operator.activities.create(:html_text=>html_text)
    @operator.save
  end  
end
