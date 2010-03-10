class Person < ActiveRecord::Base
  # one to one
  has_one :user
  # many to many through
#  has_many :relationships
#  has_many :family_members, :through=>:relationships, :class_name=>"Profie"
  #has_many :marriages
  #has_many :spouses, :through=>:marriages, :class_name=>"Person", :uniq=>true
  has_many :children, :class_name=>"Person", :finder_sql=>'SELECT * FROM people WHERE (father_id = #{id} or mother_id=#{id})'
  

  # many to many join table
  has_and_belongs_to_many :events
  
  # many to one
  belongs_to :project  
  belongs_to :father, :class_name=>"Person"
  belongs_to :mother, :class_name=>"Person"
  
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
    directory = ["public/images/person", uploader.id, time_string].join('/')
    FileUtils.mkdir_p directory
    path = [directory, name].join('/')
    File.open(path,"wb") { |f| f.write(file.read) }
    ["person", uploader.id, time_string, name].join('/')
  end
  def self.delete_file path
    FileUtils.rm path if path!=nil and File.exist?(path)
  end 
  def update_attr_from_amf new_person    
    self.first_name         = new_person.first_name
    self.last_name          = new_person.last_name
    self.sex                = new_person.sex
    self.date_of_birth      = new_person.date_of_birth
    self.is_dob_uncertain   = new_person.is_dob_uncertain
    self.deceased           = new_person.deceased
    if (self.deceased)
      self.date_of_death    = new_person.date_of_death
      self.is_dod_uncertain = new_person.is_dod_uncertain
    else
      self.date_of_death    = nil
      self.is_dod_uncertain = false
    end
    self.father_id          = new_person.father_id
    self.mother_id          = new_person.mother_id
    self.save
  end
  def marriages
    Marriage.find(:all, :conditions=>"person1_id = '#{id}' OR person2_id = '#{id}'")
  end
  def marriage_with spouse_id
    @marriages = Array.new
    marriages.each do |marriage|
      spouse = marriage.spouse_of(id)
      if spouse.id == spouse_id
        @marriages << marriage
      end
    end
    @marriages
  end
  def spouses
    @spouses = Array.new
    marriages.each do |marriage|
      @spouses << marriage.person1 if marriage.person1.id != id
      @spouses << marriage.person2 if marriage.person2.id != id        
    end
    @spouses
  end
  def children_with spouse
    childList =  Array.new
    self.children.each do |child|
      if child.father.id == spouse.id or child.mother_id == spouse.id
        childList << child
      end
    end
    childList
  end
  def destroy_marriages
    marriages.each do |marriage|
      marriage.destroy
    end
  end
end
