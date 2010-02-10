class Document < ActiveRecord::Base
  belongs_to :type, :class_name=>"DocType"
  has_and_belongs_to_many :events
  belongs_to :project
  
  def self.upload_file uploader, file
    name = File.basename(file.original_filename).gsub(/[^\w\.\-]/,'_')
    time_string = Time.now.strftime "%y%m%d%H%M%S"
    directory = ["public/documents", uploader.id, time_string].join('/')
    FileUtils.mkdir_p directory
    path = [directory, name].join('/')
    File.open(path,"wb") { |f| f.write(file.read) }
    ["/documents", uploader.id, time_string, name].join('/')
  end
  def self.delete_file path
    FileUtils.rm path if path!=nil and File.exist?(path)
  end 
end
