class AddHistoricalToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :historical, :boolean, :default=>false
  end

  def self.down
    remove_column :events, :historical
  end
end
