class Person < ActiveRecord::Base
  # one to one
  has_one :user
  # many to many through
#  has_many :relationships
#  has_many :family_members, :through=>:relationships, :class_name=>"Profie"
  has_many :marriages
  has_many :spouses, :through=>:marriages, :class_name=>"Person", :uniq=>true
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

end
