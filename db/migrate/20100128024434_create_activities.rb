class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.integer :user_id
      t.integer :project_id
      t.string  :html
      t.timestamps
    end        
  end

  def self.down
    drop_table :activities
  end
end
