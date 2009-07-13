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

ActiveRecord::Schema.define(:version => 20090623183248) do

  create_table "countries", :force => true do |t|
    t.text     "code"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dvds", :force => true do |t|
    t.text     "upc"
    t.text     "title"
    t.text     "medium_image"
    t.text     "small_image"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "country_id"
    t.text     "pageurl"
    t.text     "description"
    t.integer  "running_time"
    t.text     "theatrical_release_date"
    t.text     "dvd_release_date"
    t.integer  "region_code"
    t.text     "director"
    t.text     "actors"
    t.text     "vod"
  end

  create_table "facebook_templates", :force => true do |t|
    t.string "template_name", :null => false
    t.string "content_hash",  :null => false
    t.string "bundle_id"
  end

  add_index "facebook_templates", ["template_name"], :name => "index_facebook_templates_on_template_name", :unique => true

  create_table "imdblistings", :force => true do |t|
    t.integer  "dvd_id"
    t.integer  "imdb_id"
    t.text     "title"
    t.text     "year"
    t.text     "rating"
    t.text     "length"
    t.text     "director"
    t.text     "actors"
    t.text     "genre"
    t.text     "plot"
    t.text     "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "listings", :force => true do |t|
    t.integer  "user_id"
    t.text     "note"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "dvd_id"
  end

  create_table "torrents", :force => true do |t|
    t.integer  "dvd_id"
    t.text     "torrent"
    t.text     "link"
    t.text     "size"
    t.text     "category"
    t.text     "pubdate"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.integer  "facebook_id"
    t.string   "session_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
