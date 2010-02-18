class Event < ActiveRecord::Base
  has_and_belongs_to_many :people
  has_and_belongs_to_many :documents
  belongs_to :project
    
end
