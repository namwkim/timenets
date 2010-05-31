class ProjectController < ApplicationController
  require 'gedcom'
  require 'gedcom_date'
  def index
    @user = @operator
  end
  def show_project_list
    @user = User.find_by_id(params[:id])
    render :action=>"index"
  end
  def show_project
    @project = Project.find_by_id(params[:id])
    @root  = @project.people.first #select it more elegantly
  end
  def new_project
    @project = Project.new
    respond_to do |format|
      format.js { render :layout=>false}
    end
  end
  def create_project
    @project = Project.new(params[:project])
    @operator.projects << @project
    if @project.save
      flash[:notice] = 'Project was successfully added.'
      respond_to do |format|
        format.js { render :partial => "add_project", :locals=>{:project=>@project}}
      end      
    else      
      rende
    end
  end
  def edit_project
    @project = Project.find_by_id(params[:id])
    respond_to do |format|
      format.js { render :layout=>false}
    end
  end
  def update_project    
    if is_amf
      @project   = Project.find_by_id(params[:project].id)      
      success   = @project.update_attr_from_amf  params[:project]
    else
      @project   = Project.find_by_id(params[:id])      
      success   = @project.update_attributes(params[:project])
    end  
    if success
      respond_to do |format|
        format.js { render :partial => "update_project", :locals=>{:project=>@project} }
        format.amf { render :amf=>"Success"}
      end      
    else
      respond_to do |format|
        format.js {render :action=>"edit_project"}
        format.amf { render :amf=>FaultObject.new(@project.errors.full_messages.join("\n"))}
      end
    end
  end
  def delete_project
    @project = Project.find_by_id(params[:id])
    @project.destroy
  end
  def set_main_project
    @operator.main_project = Project.find_by_id(params[:id])
    @operator.save
    render :nothing=>true
  end
  def people
    @project = Project.find_by_id(params[:id])
    if (params[:search_person]==nil)
      @people = @project.people.paginate :page=>params[:page], :per_page=>6, :order=>"last_name"
    else
      query = "%#{params[:search_person]}%"
      @people = Person.find(:all, :conditions=>['project_id=? and (LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ?)', @project.id, query, query])
      @people = @people.paginate :page=>params[:page], :per_page=>6, :order=>"last_name"
    end    
    render :partial=>"people", :locals=>{:project=>@project, :people=>@people, :search_param=>params[:search_person]}     
  end
  def events
    @project = Project.find_by_id(params[:id])
    if (params[:search_event]==nil)
      @events = @project.events.paginate :page=>params[:page], :per_page=>6, :order=>"name"
    else
      query = "%#{params[:search_event]}%"
      @events = Event.find(:all, :conditions=>['project_id=? and (LOWER(name) LIKE ?)', @project.id, query])
      @events = @events.paginate :page=>params[:page], :per_page=>6, :order=>"name"
    end    
    render :partial=>"events", :locals=>{:project=>@project, :events=>@events}
  end
  def documents
    @project = Project.find_by_id(params[:id]) 
    if (params[:search_document]==nil)
      @documents = @project.documents.paginate :page=>params[:page], :per_page=>6, :order=>"name"
    else
      query = "%#{params[:search_document]}%"
      @documents = Document.find(:all, :conditions=>['project_id=? and (LOWER(name) LIKE ?)', @project.id, query])
      @documents = @documents.paginate :page=>params[:page], :per_page=>6, :order=>"name"
    end   
    render :partial=>"documents", :locals=>{:project=>@project, :documents=>@documents}
  end
  def gedcom
    @project  = Project.find_by_id(params[:id])    
    respond_to do |format|
      format.html {}
      format.js { render :layout=>false }
    end
  end
  def gedcom_import
    @project  = Project.find_by_id(params[:id])
    if params[:gedcom_file]!=nil
      people    = Hash.new
      families  = Hash.new
      curPerson = curFamily = nil      
      parser = GEDCOM::Parser.new do
        ######################################## INDIVIDUAL ####
        before %(INDI) do |id|
          people[id] = curPerson = Person.new
        end
        before %w(INDI NAME) do |name|
          tokens = name.split(" ", 2)
          curPerson.first_name = tokens[0]
          curPerson.last_name = tokens[1] if tokens.length>1         
        end
        before %w(INDI SEX) do |sex|
          if sex=="M"
            curPerson.sex = "Male"
          elsif sex=="F"
            curPerson.sex = "Female"
          end          
        end
        before %w(INDI BIRT DATE) do |birth_date|        
          curPerson.date_of_birth     = birth_date          
        end
        before %w(INDI DEAT DATE) do |death_date|
          curPerson.deceased          = true 
          curPerson.date_of_death     = death_date           
        end
        ######################################## FAMILY ####
        before %(FAM) do |id|
          families[id] = curFamily = Hash.new          
        end
        before %w(FAM HUSB) do |fid|
          curFamily["HUSB"] = fid
        end
        before %w(FAM WIFE) do |mid|
          curFamily["WIFE"] = mid
        end
        before %w(FAM CHIL) do |cid|
          curFamily["CHIL"] = Array.new if curFamily["CHIL"].nil?
          curFamily["CHIL"].push(cid)
        end
        before %w(FAM MARR DATE) do |mar_date|
          curFamily["MARR DATE"] = mar_date
        end
        before %w(FAM DIV) do |divorced| # How do we deal with the case when divorce date is not supplied, but divorced=="Y"
          curFamily["DIV"] = divorced=="Y"? true:false
        end
        before %w(FAM DIV DATE) do |div_date|
          curFamily["DIV"]      = true
          curFamily["DIV DATE"] = div_date
        end
      end
      parser.parse params[:gedcom_file].path
      ##### Save into Database
      people.each do |id, person|
        person.project = @project
        person.save
      end
      families.each do |id, family|
        father = people[family["HUSB"]]
        mother = people[family["WIFE"]]
        
        #create marriage
        marriage = Marriage.new
        marriage.person1_id = father.id
        marriage.person2_id = mother.id
        marriage.start_date = family["MARR DATE"] if family["MARR DATE"]!=nil
        marriage.divorced   = family["DIV"] if family["DIV"]!=nil 
        marriage.end_date   = family["DIV DATE"] if family["DIV DATE"]!=nil
        marriage.save
        
        #create parent-child relationships
        if family["CHIL"]!=nil
          family["CHIL"].each do |cid|
            child = people[cid]
            child.father = father
            child.mother = mother
            child.save
          end
        end        
      end
      respond_to do |format|
        format.js   { 
          responds_to_parent do
            render :partial => "gedcom_import", :locals=>{:project=>@project}
          end
        }
      end
    else
       render :nothing=>true
    end
  end
private
  def change_data_type
    if params[:html_format]==nil or params[:html_format]!="true"
      request.format = :js if is_amf!=true
    end    
  end 
end
