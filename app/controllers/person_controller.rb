class PersonController < ApplicationController
  require 'lightbox_helper'
  before_filter :change_data_type, :only=>[:create_person, :create_person_in_event, :update_person, :update_person_in_event]
  def index
    @person = @operator.person
  end
  def visualize
    @person = Person.find_by_id(params[:id])
  end
  def root #called from flex to get a genealogy root
    @person = Person.find_by_id(params[0])
    render :amf=>@person
  end
  def new_person
    @person = Person.new
    @action = "create_person"
    @project_id = params[:project_id]
    respond_to do |format|
      format.html {}
      format.js { render :layout=>false }
    end
  end
  def create_person      
    @person = build_person params
    @person.project = Project.find_by_id(params[:project_id])
    if @person.save      
      log "created", @person, @person.project
      respond_to do |format|
        format.html {redirect_to(:action=>"index")}
        format.js { 
          responds_to_parent do 
            render :partial=>"add_person", :locals=>{:person=>@person}
          end
        }    
      end
    else
        render :action=>"new_person"
    end
  end

  def edit_person
    @person  = Person.find_by_id(params[:id])
    @action   = "update_person"
    respond_to do |format|
      format.html{  @html_format = true }
      format.js{ render :layout=>false}
    end
  end
  
  def update_person
    @person = Person.find_by_id(params[:id])
    if update_person_attributes @person, params
      log "edited", @person, @person.project
      respond_to do |format|
        format.html {redirect_to(:action=>"index")}
        format.js { 
          responds_to_parent do 
            render :partial=>"update_person", :locals=>{:person=>@person}
          end
        }
      end
    else
      render :action=>"edit_person"
    end
  end
    
  def show_person
    @person = Person.find_by_id(params[:id])
    render :action=>"index"
  end
  
  def delete_person
    @person = Person.find_by_id(params[:id])
    Person.delete_file(@person.photo_url)
    Person.destroy(@person)
    log "deleted", @person, @person.project
    render :nothing=>true
  end
  ############################## Relationship ##############################
  def new_relationship
    @action = params[:action]
  end
  def new_relationship
    @person  = Person.new
    @ref_id   = params[:ref_id]
    @role     = params[:role]
    if @role == "Spouse"
      @person.marriages.build
    end
    render :layout=>false
  end
  def create_relationship
    if params[:person_id]!=nil
      @person = Person.find_by_id(params[:person_id]) # create a relationship from existing person
    else      
      @person = is_amf ? params[:person] : Person.new(params[:person])
    end
    @ref_person = Person.find_by_id(params[:ref_id])
    @person.project = @ref_person.project # inherit project
    @role = params[:role] # new person's role
    case @role #spouse is automatically handled
      when "Father"
        @ref_person.father = @person
      when "Mother"
        @ref_person.mother = @person
      when "Spouse"
        @person.marriages.build(params[:marriage])     
      when "Child"
        case @ref_person.sex  #TODO: what if sex is nil
          when "Male"
            @person.father = @ref_person
          else "Female"
            @person.mother = @ref_person
        end              
    end
    if @person.save and @ref_person.save
      if @role == "Spouse"
        params[:marriage][:person_id]= @ref_person.id
        params[:marriage][:spouse_id] = @person.id
        @ref_person.marriages.create(params[:marriage]) #TODO: improve this crud synchronization...   
      end
      flash[:notice] = 'Person was successfully added.'
      respond_to do |format|
        format.html {}
        format.js { render :partial => "add_relationship", :locals=>{:person=>@person, :role=>@role, :ref_person=>@ref_person} }
        format.amf { render :amf=>{:person=>@person, :role=>@role, :ref_id=>@ref_person.id}  }
      end      
    else
      render :action => "new_relationship"
    end
  end
  def delete_relationship    
    @person = Person.find_by_id(params[:id])
    @ref_person = Person.find_by_id(params[:ref_id])
    case params[:role]
      when "Father"
        @ref_person.father = nil
      when "Mother"
        @ref_person.mother = nil
      when "Spouse"        
        @ref_person.spouses.delete(@person)
        @person.spouses.delete(@ref_person)
      when "Child"
        case @ref_person.sex  #TODO: what if sex is nil
          when "Male"
            @person.father = nil
          else "Female"
            @person.mother = nil
        end    
    end
    @ref_person.save
    @person.save
    render :nothing=>true
  end
  def edit_marriage
    
  end
  def update_marriage
    
  end
  def edit_relationships
    @person =  Person.find_by_id(params[:id])
  end
  def auto_complete_for_person_name
    query = params[:person_name]
    query = "%#{query}%"
    @people = Person.find(
      :all,
      :conditions => ['project_id=? and (LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ?)', params[:project_id], query, query],
      :limit => 10
    )
    render :partial => 'person_completions'
  end
  ############################## Event ##############################
  def new_person_in_event
    @person = Person.new
    @action = "create_person_in_event"
    @project_id = params[:project_id]
    @event_id   = params[:event_id] #could be null if called from new_event
    render :action=>"new_person", :layout=>false
  end
  def create_person_in_event
    @person = build_person params
    @person.project = Project.find_by_id(params[:project_id])
    if @person.save      
      if params[:event_id].nil?  #new event
        session[:people] << @person.id
      else #edit event or show event
        @event = Event.find_by_id(params[:event_id])
        @event.people << @person
      end      
      log "created", @person, @person.project
      responds_to_parent do 
        render :partial=>"add_person_in_event", :locals=>{:person=>@person, :event=>@event}  
      end
    else
      render :action=>"new_person_in_event"
    end
  end
  def edit_person_in_event
    @person = Person.find_by_id(params[:id])
    @action  = "update_person_in_event"
    @event_id = params[:event_id]
    render :action=>"edit_person", :layout=>false
  end
  def update_person_in_event
    @person = Person.find_by_id(params[:id])
    if update_person_attributes @person, params
      @event = Event.find_by_id(params[:event_id]) if params[:event_id]!=nil
      log "edited", @person, @person.project
      responds_to_parent do
        render :partial=>"update_person_in_event", :locals=>{:person=>@person, :event=>@event}
      end      
    else
      render :action=>"edit_person_in_event"
    end
  end
  def delete_person_in_event
    @person = Person.find_by_id(params[:id])
    if params[:event_id]!=nil
      @event  = Event.find_by_id(params[:event_id])      
      @event.people.delete(@person)
    else
      session[:people].delete(@person.id)
    end
    render :nothing=>true
  end
  def add_person_in_event
    @person = Person.find_by_id(params[:person_id])
    if params[:event_id]!=nil
      @event = Event.find_by_id([params[:event_id]])
      @event.people << @person
    else
      session[:people] << @person.id
    end    
    render :partial=>"add_person_in_event", :locals=>{:person=>@person, :event=>@event}
  end

private
  def change_data_type
    if params[:html_format]==nil or params[:html_format]!="true"
      request.format = :js
    end    
  end

  def build_person params
    if (params[:person][:photo_url] != nil)
      params[:person][:photo_url] = Person.upload_file(@operator, params[:person][:photo_url])
    end
    Person.new(params[:person])
  end

  def update_person_attributes person, params    
    if (params[:person][:photo_url] != nil)
      params[:person][:photo_url] = Person.upload_file(@operator, params[:person][:photo_url])
      Person.delete_file(person.photo_url)
    end
    person.update_attributes(params[:person])
  end



end
