class CreateStudyInfos < ActiveRecord::Migration
  def self.up
    create_table :study_infos do |t|
      t.integer :study_code
      t.integer :user_id
      t.integer :rep_type    
      t.timestamps
    end
  end

  def self.down
    drop_table :study_infos
  end
end
