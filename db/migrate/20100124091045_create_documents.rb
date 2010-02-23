class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.integer :project_id
      t.string  :name
      t.integer :type_id #video, photo, document
      t.string  :file_url
      t.text    :description
      t.timestamps
    end
    create_table :doc_types do |t|
      t.string  :name
      t.string  :description
    end
    DocType.create(:name => "Photo")
    DocType.create(:name => "Video")
    DocType.create(:name => "Audio")
    DocType.create(:name => "Other")
  end
  def self.down
    drop_table :documents
    drop_table :doc_types
  end
end
