class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer :person_id
      t.integer :project_id
      t.string  :email
      t.string  :hashed_password
      t.string  :salt
      t.string  :role,  :default=>"User"
      t.timestamps
    end
#    #collaboration table
#    create_table  :collaborators, :id=>false do |t|
#      t.integer :user_id
#      t.integer :collaborator_id
#    end
    #managed profiles
    create_table :managed_projects do |t|
      t.integer :user_id
      t.integer :project_id
      t.string  :privilege, :default=>"Editor"
    end
    user1 = User.create(:email => "namwkim85@gmail.com", :password => "password")
    user2 = User.create(:email=>"countis85@gmail.com", :password=>"password")
#    user1.collaborators << user2
#    user2.collaborators << user1
  end

  def self.down
    drop_table :users
    drop_table :managed_projects
    #drop_table :collaborators
  end
end
