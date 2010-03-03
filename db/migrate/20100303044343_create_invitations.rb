class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.integer :sender_id
      t.integer :project_id
      t.string  :recipient_email
      t.string  :token
      t.string  :message
      t.boolean :accepted,  :default=>0
      t.date    :sent_at
    end
  end

  def self.down
    drop_table :invitations
  end
end
