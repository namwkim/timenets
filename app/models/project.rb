class Project < ActiveRecord::Base
  has_many :managed_projects, :dependent=>:destroy
  has_many :users, :through=>:managed_projects, :uniq=>true
  has_many :people, :dependent=>:destroy
  has_many :revisions, :dependent=>:destroy
  has_many :events, :dependent=>:destroy
  has_many :documents, :dependent=>:destroy
  has_many :activities, :dependent=>:destroy
end
