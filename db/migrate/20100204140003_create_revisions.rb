class CreateRevisions < ActiveRecord::Migration
  def self.up
    create_table :revisions do |t|
      t.integer :user_id
      t.integer :project_id
      t.integer :record_id
      t.string  :record_type #profile, document, event, relationship
      t.timestamps
    end
  end

  def self.down
    drop_table :revisions
  end
end
