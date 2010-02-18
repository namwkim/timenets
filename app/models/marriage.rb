class Marriage < ActiveRecord::Base
  belongs_to  :person
  belongs_to  :spouse,  :class_name=>"Person"
  
  def conjugate
    Marriage(:first, :conditions=>["person_id=? and spouse_id=?", person_id, spouse_id])
  end
end
