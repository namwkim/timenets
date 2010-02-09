class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.integer :user_id
      t.text  :html_text
      t.timestamps
    end
  end

  def self.down
    drop_table :activities
  end
end
