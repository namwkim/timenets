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
  
  def copy
    map = Hash.new
    project = self.clone
    project.save
    #clone individual records    
    self.people.each do |person|
      map[person.id] = person.clone
      map[person.id].save
    end
    #clone relationship records
    mar_map = Hash.new
    self.people.each do |ref_person|
      #parent-child relationship
      person  = map[ref_person.id]
      if ref_person.father!=nil
        father  = map[ref_person.father.id]
        person.father = father
      end
      if ref_person.mother!=nil
        mother  = map[ref_person.mother.id]      
        person.mother = mother        
      end      
      #marriages
      ref_person.marriages.each do |ref_marriage|
        if mar_map[ref_marriage.id].nil?
          marriage  = mar_map[ref_marriage.id] = ref_marriage.clone
          marriage.person1_id = map[ref_marriage.person1_id].id
          marriage.person2_id = map[ref_marriage.person2_id].id
          marriage.save
        end
      end
      
      #project
      project.people<<person      
    end
    project
  end
end
