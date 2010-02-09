class CreateRelationships < ActiveRecord::Migration
  def self.up
    #Relationship
    create_table :relationships do |t|
      t.integer :profile_id
      t.integer :family_member_id
      t.integer :type_id
      t.integer :profile_role_id
      t.integer :family_member_role_id
      t.date    :start_date
      t.date    :end_date      
      t.timestamps
    end
    
    #Relationship Type
    create_table  :relationship_types do |t|
      t.string  :name
      t.string  :description
    end
    RelationshipType.create(:name => "Marriage")
    RelationshipType.create(:name => "Parent-Child")
    
    #Roles
    create_table  :roles do |t|
      t.string  :name
      t.string  :description
    end
    
    Role.create(:name => "Father")
    Role.create(:name => "Mother")
    Role.create(:name => "Child")
    Role.create(:name => "Spouse")
    
    
    #Role Type
  end

  def self.down
    drop_table :relationships
    drop_table :relationship_types
    drop_table :roles
  end
end
