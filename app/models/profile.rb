class Profile < ActiveRecord::Base
  # one to one
  has_one :user
  # many to many through
  has_many :relationships
  has_many :family_members, :through=>:relationships, :class_name=>"Profie"
  
  # many to many join table
  has_and_belongs_to_many :events
  
  # many to one
  belongs_to :project  
  def name
    if self.first_name!=nil and self.last_name!=nil
      self.first_name+" "+self.last_name
    elsif self.first_name.nil?
      self.last_name      
    else
      self.first_name
    end
  end
  def self.upload_file uploader, file
    name = File.basename(file.original_filename).gsub(/[^\w\.\-]/,'_')
    time_string = Time.now.strftime "%y%m%d%H%M%S"
    directory = ["public/images/profile", uploader.id, time_string].join('/')
    FileUtils.mkdir_p directory
    path = [directory, name].join('/')
    File.open(path,"wb") { |f| f.write(file.read) }
    ["profile", uploader.id, time_string, name].join('/')
  end
  def self.delete_file path
    FileUtils.rm path if path!=nil and File.exist?(path)
  end 
  def self.marriage person1, person2
    
  end
  ########## method retrieving family members ###########
  def spouses
    @spouses = Array.new
    @marriages.each {|rel| @spouses << rel.family_member} if @marriages!=nil   
    @spouses
  end
  def marriages
    @marriages = self.relationships.find_all_by_type_id(RelationshipType.find_by_name("Marriage").id)
    @marriages
  end
  def father
    rel = self.relationships.find_by_family_member_role_id(Role.find_by_name("Father").id)
    @father = rel.family_member if rel!=nil
    @father
  end
  def mother
    rel = self.relationships.find_by_family_member_role_id(Role.find_by_name("Mother").id)
    @mother = rel.family_member if rel!=nil
    @mother
  end
  def children
    @children = Array.new
    rels = self.relationships.find_all_by_family_member_role_id(Role.find_by_name("Child").id)
    rels.each {|rel| @children << rel.family_member} if rels!=nil      
    @children
  end

end
