class RenameEventColumns < ActiveRecord::Migration
  def self.up
    rename_column :events, :from, :start
    rename_column :events, :to, :end
    rename_column :events, :isRange, :is_range
  end

  def self.down
    rename_column :events, :start, :from
    rename_column :events, :end, :to
    rename_column :events, :is_range, :isRange
  end
end
