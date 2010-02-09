class Relationship < ActiveRecord::Base
  belongs_to  :profile, :class_name => "Profile"
  belongs_to  :family_member, :class_name => "Profile"
  belongs_to  :profile_role, :class_name => "Role"
  belongs_to  :family_member_role, :class_name => "Role"
  belongs_to  :relationship_type, :foreign_key=>:type_id
  
  def conjugate
    self.family_member.relationships.find_by_family_member_id(self.profile.id)
  end
end
