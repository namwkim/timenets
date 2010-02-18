class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string  :name
      t.string  :description
      t.timestamps
    end
    project1 = Project.create(:name=>"Genealogy Project1",:description=>"This is a genealogy project.")
    project2 = Project.create(:name=>"Genealogy Project2",:description=>"This is a genealogy project.")
    user1 = User.find_by_id(1) 
    user2 = User.find_by_id(2)   
    user1.managed_projects.create(:project_id=>project1.id)
    user2.managed_projects.create(:project_id=>project1.id)
    user2.managed_projects.create(:project_id=>project2.id)
    project1.people << user1.person
    project2.people << user2.person
    user1.main_project = project1
    user2.main_project = project1
    user1.save
    user2.save
    
    str1 = user1.person.name+" joined "+project1.name
    str2 = user2.person.name+" joined "+project1.name
    str3 = user2.person.name+" joined "+project2.name
    Activity.create(:user_id=>user1.id, :project_id=>project1.id, :html=>str1)
    Activity.create(:user_id=>user2.id, :project_id=>project1.id, :html=>str2)
    Activity.create(:user_id=>user2.id, :project_id=>project2.id, :html=>str3)
      
  end

  def self.down
    drop_table :projects
  end
end
