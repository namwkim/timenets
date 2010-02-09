class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.integer :project_id
      t.string  :first_name
      t.string  :last_name
      t.string  :sex
      t.date    :date_of_birth
      t.date    :date_of_death   
      t.boolean :deceased,  :defalut=>0
      t.string  :photo_url
      t.timestamps
    end
    create_table  :events_profiles, :id=>false do |t|
      t.integer :profile_id
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
     user.create_profile(:first_name => "Nam Wook",
                  :last_name => "Kim",
                  :sex => "Male",
                  :date_of_birth => "1985-01-20")
     user.save
     user = User.find_by_id(2)
     user.create_profile(:first_name => "Nam Gyun",
                  :last_name => "Kim",
                  :sex => "Male",
                  :date_of_birth => "1983-6-13")
     user.save
  end

  def self.down
    drop_table :profiles
    drop_table :profiles_events
  end
end
