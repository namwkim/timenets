class Marriage < ActiveRecord::Base
  belongs_to  :person1, :class_name=>"Person"
  belongs_to  :person2, :class_name=>"Person"
  
  def spouse_of person_id
    @spouse = person1.id==person_id ? person2 : person1
  end
  def update_attr_from_amf new_marriage
    self.start_date         = new_marriage.start_date
    self.is_start_uncertain = new_marriage.is_start_uncertain
    self.divorced           = new_marriage.divorced
    self.end_date           = new_marriage.end_date if self.divorced
    self.is_end_uncertain   = new_marriage.is_end_uncertain if self.divorced
    self.save
  end
end
