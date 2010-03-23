class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.integer :project_id
      t.string  :name
      t.string  :location
      t.date    :from 
      t.date    :to #null if not range
      t.boolean :isRange,   :default => false
      t.text    :description
      t.timestamps
    end
    create_table :documents_events, :id=>false do |t|
      t.integer :event_id
      t.integer :document_id
    end
  end
    
   create_table  :events_people, :id=>false do |t|
      t.integer :person_id
      t.integer :event_id
    end
  def self.down
    drop_table :events
    drop_table :documents_events
    drop_table :events_people
  end
end
