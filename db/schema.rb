# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100315103202) do

  create_table "activities", :force => true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.string   "html"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "doc_types", :force => true do |t|
    t.string "name"
    t.string "description"
  end

  create_table "documents", :force => true do |t|
    t.integer  "project_id"
    t.string   "name"
    t.integer  "type_id"
    t.string   "file_url"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "documents_events", :id => false, :force => true do |t|
    t.integer "event_id"
    t.integer "document_id"
  end

  create_table "events", :force => true do |t|
    t.integer  "project_id"
    t.string   "name"
    t.string   "location"
    t.date     "start"
    t.date     "end"
    t.boolean  "is_range",    :default => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "historical",  :default => false
  end

  create_table "events_people", :id => false, :force => true do |t|
    t.integer "person_id"
    t.integer "event_id"
  end

  create_table "invitations", :force => true do |t|
    t.integer "sender_id"
    t.integer "project_id"
    t.string  "recipient_email"
    t.string  "token"
    t.string  "message"
    t.boolean "accepted",        :default => false
    t.date    "sent_at"
  end

  create_table "managed_projects", :force => true do |t|
    t.integer "user_id"
    t.integer "project_id"
    t.string  "privilege",  :default => "Editor"
  end

  create_table "marriages", :force => true do |t|
    t.integer "person1_id"
    t.integer "person2_id"
    t.boolean "divorced"
    t.date    "start_date"
    t.date    "end_date"
    t.boolean "is_start_uncertain"
    t.boolean "is_end_uncertain"
  end

  create_table "messages", :force => true do |t|
    t.text     "text"
    t.integer  "from_id"
    t.integer  "to_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", :force => true do |t|
    t.integer  "project_id"
    t.integer  "father_id"
    t.integer  "mother_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "sex"
    t.date     "date_of_birth"
    t.date     "date_of_death"
    t.boolean  "deceased"
    t.string   "photo_url"
    t.boolean  "is_dob_uncertain"
    t.boolean  "is_dod_uncertain"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "revisions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.integer  "record_id"
    t.string   "record_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.integer  "person_id"
    t.integer  "project_id"
    t.integer  "invitation_id"
    t.string   "email"
    t.string   "hashed_password"
    t.string   "salt"
    t.string   "role",            :default => "User"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
