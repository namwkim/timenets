class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.text  :text
      t.integer :from_id
      t.integer :to_id
      t.timestamps
    end
    Message.create
  end

  def self.down
    drop_table :messages
  end
end
