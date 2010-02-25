class Marriage < ActiveRecord::Base
  belongs_to  :person1, :class_name=>"Person"
  belongs_to  :person2, :class_name=>"Person"
  
  def spouse_of person_id
    @spouse = person1.id==person_id ? person2 : person1
  end
end
