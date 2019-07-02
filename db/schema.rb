# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_04_27_095602) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attendances", force: :cascade do |t|
    t.datetime "date"
    t.boolean "present"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "standard_id"
    t.bigint "student_id"
    t.bigint "school_id"
    t.boolean "sms_sent"
    t.index ["school_id"], name: "index_attendances_on_school_id"
    t.index ["standard_id"], name: "index_attendances_on_standard_id"
    t.index ["student_id"], name: "index_attendances_on_student_id"
  end

  create_table "schools", force: :cascade do |t|
    t.string "name", null: false
    t.string "address"
    t.string "school_code", null: false
    t.time "start_time"
    t.time "close_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "staffs", force: :cascade do |t|
    t.string "mobile_number", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "registration_no", null: false
    t.string "name"
    t.string "designation"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "auth_token"
    t.bigint "school_id"
    t.index ["mobile_number"], name: "index_staffs_on_mobile_number", unique: true
    t.index ["reset_password_token"], name: "index_staffs_on_reset_password_token", unique: true
    t.index ["school_id"], name: "index_staffs_on_school_id"
  end

  create_table "staffs_standards", id: false, force: :cascade do |t|
    t.bigint "standard_id", null: false
    t.bigint "staff_id", null: false
    t.index ["staff_id", "standard_id"], name: "index_staffs_standards_on_staff_id_and_standard_id"
    t.index ["standard_id", "staff_id"], name: "index_staffs_standards_on_standard_id_and_staff_id"
  end

  create_table "standard_attendances", force: :cascade do |t|
    t.date "date"
    t.integer "no_of_student_present"
    t.integer "no_of_absent_student"
    t.boolean "attendance_marked", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "standard_id"
    t.bigint "school_id"
    t.index ["school_id"], name: "index_standard_attendances_on_school_id"
    t.index ["standard_id"], name: "index_standard_attendances_on_standard_id"
  end

  create_table "standards", force: :cascade do |t|
    t.string "standard"
    t.string "section"
    t.time "start_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "school_id"
    t.index ["school_id"], name: "index_standards_on_school_id"
  end

  create_table "student_translations", force: :cascade do |t|
    t.integer "student_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["locale"], name: "index_student_translations_on_locale"
    t.index ["student_id"], name: "index_student_translations_on_student_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "name"
    t.string "registration_no"
    t.integer "roll_no"
    t.string "gender"
    t.datetime "dob"
    t.string "guardian_name"
    t.string "guardian_mobile_no"
    t.string "guardian_alternate_mobile_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address"
    t.bigint "school_id"
    t.bigint "standard_id"
    t.index ["school_id"], name: "index_students_on_school_id"
    t.index ["standard_id"], name: "index_students_on_standard_id"
  end

  add_foreign_key "attendances", "schools"
  add_foreign_key "attendances", "standards"
  add_foreign_key "attendances", "students"
  add_foreign_key "staffs", "schools"
  add_foreign_key "standard_attendances", "schools"
  add_foreign_key "standard_attendances", "standards"
  add_foreign_key "standards", "schools"
  add_foreign_key "students", "schools"
  add_foreign_key "students", "standards"
end
