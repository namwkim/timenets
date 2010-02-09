class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string  :name
      t.string  :description
      t.timestamps
    end
    project1 = Project.create(:name=>"Genealogy Project1",:description=>"This is a genealogy project.")
    project2 = Project.create(:name=>"Genealogy Project2",:description=>"This is a genealogy project.")
    ManagedProject.create(:user_id=>1, :project_id=>project1.id)
    ManagedProject.create(:user_id=>2, :project_id=>project1.id)
    ManagedProject.create(:user_id=>2, :project_id=>project2.id)
    project1.profiles << Profile.find_by_id(1) 
    project2.profiles << Profile.find_by_id(2)     
      
  end

  def self.down
    drop_table :projects
  end
end
