class Project < ActiveRecord::Base
  has_many :managed_projects, :dependent=>:destroy
  has_many :users, :through=>:managed_projects, :uniq=>true
  has_many :people, :dependent=>:destroy
  has_many :revisions, :dependent=>:destroy
  has_many :events, :dependent=>:destroy
  has_many :documents, :dependent=>:destroy
  has_many :activities, :dependent=>:destroy
  def update_attr_from_amf new_project
    self.name         = new_project.name
    self.description  = new_project.description
    self.save    
  end
end
