# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_12_215403) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "aid_applications", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "organization_id", null: false
    t.text "street_address"
    t.text "city"
    t.text "zip_code"
    t.text "phone_number"
    t.text "email"
    t.datetime "submitted_at"
    t.bigint "submitter_id"
    t.string "application_number"
    t.bigint "creator_id", null: false
    t.boolean "receives_calfresh_or_calworks"
    t.boolean "unmet_food"
    t.boolean "unmet_housing"
    t.boolean "unmet_childcare"
    t.boolean "unmet_utilities"
    t.boolean "unmet_transportation"
    t.boolean "unmet_other"
    t.boolean "valid_work_authorization"
    t.boolean "covid19_reduced_work_hours"
    t.boolean "covid19_care_facility_closed"
    t.boolean "covid19_experiencing_symptoms"
    t.boolean "covid19_underlying_health_condition"
    t.boolean "covid19_caregiver"
    t.text "name"
    t.date "birthday"
    t.text "preferred_language"
    t.text "country_of_origin"
    t.text "sexual_orientation"
    t.text "gender"
    t.string "racial_ethnic_identity", array: true
    t.boolean "sms_consent"
    t.boolean "email_consent"
    t.text "apartment_number"
    t.boolean "allow_mailing_address"
    t.text "mailing_street_address"
    t.text "mailing_apartment_number"
    t.text "mailing_city"
    t.text "mailing_state"
    t.text "mailing_zip_code"
    t.boolean "landline"
    t.boolean "attestation"
    t.index ["application_number"], name: "index_aid_applications_on_application_number", unique: true
    t.index ["creator_id"], name: "index_aid_applications_on_creator_id"
    t.index ["organization_id"], name: "index_aid_applications_on_organization_id"
    t.index ["submitter_id"], name: "index_aid_applications_on_submitter_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "name", null: false
    t.integer "users_count", default: 0, null: false
    t.integer "aid_applications_count", default: 0, null: false
    t.integer "total_payment_cards_count", default: 0, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.bigint "organization_id"
    t.integer "aid_applications_count", default: 0, null: false
    t.boolean "admin", default: false, null: false
    t.boolean "supervisor", default: false, null: false
    t.bigint "inviter_id"
    t.datetime "deactivated_at"
    t.bigint "aid_applications_created_count", default: 0, null: false
    t.bigint "aid_applications_submitted_count", default: 0, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["deactivated_at", "id"], name: "index_users_on_deactivated_at_and_id", order: :desc
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["inviter_id"], name: "index_users_on_inviter_id"
    t.index ["organization_id", "deactivated_at", "id"], name: "index_users_on_organization_id_and_deactivated_at_and_id", order: { deactivated_at: :desc, id: :desc }
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.jsonb "object"
    t.jsonb "object_changes"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "aid_applications", "organizations"
  add_foreign_key "aid_applications", "users", column: "creator_id"
  add_foreign_key "aid_applications", "users", column: "submitter_id"
  add_foreign_key "users", "organizations"
  add_foreign_key "users", "users", column: "inviter_id"

  create_view "aid_application_searches", materialized: true, sql_definition: <<-SQL
      SELECT aid_applications.id AS aid_application_id,
      ((((((((((((aid_applications.id || ' '::text) || COALESCE(aid_applications.name, ''::text)) || ' '::text) || COALESCE(aid_applications.street_address, ''::text)) || ' '::text) || COALESCE(aid_applications.city, ''::text)) || ' '::text) || COALESCE(aid_applications.zip_code, ''::text)) || ' '::text) || COALESCE(aid_applications.email, ''::text)) || ' '::text) || COALESCE(aid_applications.phone_number, ''::text)) AS searchable_data
     FROM aid_applications;
  SQL
  add_index "aid_application_searches", "to_tsvector('english'::regconfig, searchable_data)", name: "index_aid_application_searches_on_searchable_data", using: :gin
  add_index "aid_application_searches", ["aid_application_id"], name: "index_aid_application_searches_on_aid_application_id", unique: true

end
