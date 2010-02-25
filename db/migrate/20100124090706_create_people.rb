class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.integer :project_id
      t.integer :father_id
      t.integer :mother_id
      t.string  :first_name
      t.string  :last_name
      t.string  :sex
      t.date    :date_of_birth
      t.date    :date_of_death   
      t.boolean :deceased,  :defalut=>0
      t.string  :photo_url
      t.boolean :is_dob_uncertain
      t.boolean :is_dod_uncertain
      t.timestamps
    end
    create_table  :marriages do |t|
      t.integer :person1_id
      t.integer :person2_id
      t.boolean :divorced
      t.date    :start_date
      t.date    :end_date 
      t.boolean :is_start_uncertain
      t.boolean :is_end_uncertain
    end
    create_table  :events_people, :id=>false do |t|
      t.integer :person_id
      t.integer :event_id
    end
#    profile = Profile.create(:first_name => "Nam Wook",
#                  :last_name => "Kim",
#                  :sex => "Male",
#                  :date_of_birth => "1985-01-20")
#    user = User.find_by_id(1)
#    user.profile = profile
#    user.save
     user = User.find_by_id(1)
     user.create_person(:first_name => "Nam Wook",
                  :last_name => "Kim",
                  :sex => "Male",
                  :date_of_birth => "1985-01-20")
     user.save
     user = User.find_by_id(2)
     user.create_person(:first_name => "Nam Gyun",
                  :last_name => "Kim",
                  :sex => "Male",
                  :date_of_birth => "1983-6-13")
     user.save
  end

  def self.down
    drop_table :people
    drop_table :events_people
    drop_table :marriages
  end
end
