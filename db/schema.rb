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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110607232520) do

  create_table "activities", :force => true do |t|
    t.integer  "user_id"
    t.integer  "partner_id"
    t.string   "type",                 :limit => 60
    t.string   "status",               :limit => 8
    t.integer  "priority_id"
    t.datetime "created_at"
    t.boolean  "is_user_only",                       :default => false
    t.integer  "comments_count",                     :default => 0
    t.integer  "activity_id"
    t.integer  "vote_id"
    t.integer  "change_id"
    t.integer  "other_user_id"
    t.integer  "tag_id"
    t.integer  "point_id"
    t.integer  "revision_id"
    t.integer  "capital_id"
    t.integer  "ad_id"
    t.integer  "document_id"
    t.integer  "document_revision_id"
    t.integer  "position"
    t.integer  "followers_count",                    :default => 0
    t.datetime "changed_at"
  end

  add_index "activities", ["activity_id"], :name => "activity_activity_id"
  add_index "activities", ["ad_id"], :name => "activities_ad_id_index"
  add_index "activities", ["change_id"], :name => "activities_change_id_index"
  add_index "activities", ["changed_at"], :name => "index_activities_on_changed_at"
  add_index "activities", ["created_at"], :name => "created_at"
  add_index "activities", ["document_id"], :name => "index_activities_on_document_id"
  add_index "activities", ["document_revision_id"], :name => "index_activities_on_document_revision_id"
  add_index "activities", ["is_user_only"], :name => "activity_is_user_only_index"
  add_index "activities", ["point_id"], :name => "activity_point_id_index"
  add_index "activities", ["priority_id"], :name => "activity_priority_id_index"
  add_index "activities", ["revision_id"], :name => "index_activities_on_revision_id"
  add_index "activities", ["status"], :name => "activity_status_index"
  add_index "activities", ["type"], :name => "activity_type_index"
  add_index "activities", ["user_id"], :name => "activity_user_id_index"
  add_index "activities", ["vote_id"], :name => "activities_vote_id_index"

  create_table "ads", :force => true do |t|
    t.integer  "priority_id"
    t.integer  "user_id"
    t.integer  "show_ads_count",                 :default => 0
    t.integer  "shown_ads_count",                :default => 0
    t.integer  "cost"
    t.float    "per_user_cost"
    t.float    "spent",                          :default => 0.0
    t.integer  "yes_count",                      :default => 0
    t.integer  "no_count",                       :default => 0
    t.integer  "skip_count",                     :default => 0
    t.string   "status",          :limit => 40
    t.string   "content",         :limit => 140
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "finished_at"
    t.integer  "position",                       :default => 0
    t.integer  "partner_id"
  end

  add_index "ads", ["priority_id"], :name => "ads_priority_id_index"
  add_index "ads", ["status"], :name => "ads_status_index"

  create_table "blasts", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "status"
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.integer  "tag_id"
    t.string   "code",         :limit => 40
    t.integer  "clicks_count",               :default => 0
  end

  add_index "blasts", ["code"], :name => "blasts_code_index"
  add_index "blasts", ["name"], :name => "blasts_name_index"
  add_index "blasts", ["status"], :name => "blasts_status_index"
  add_index "blasts", ["type"], :name => "blasts_type_index"
  add_index "blasts", ["user_id"], :name => "blast_user_id_index"

  create_table "capitals", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.integer  "capitalizable_id"
    t.string   "capitalizable_type"
    t.integer  "amount",                           :default => 0
    t.string   "type",               :limit => 60
    t.string   "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "capitals", ["recipient_id"], :name => "capitals_recipient_id_index"
  add_index "capitals", ["sender_id"], :name => "capitals_sender_id_index"
  add_index "capitals", ["type"], :name => "capitals_type_index"

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "partner_id"
    t.string   "icon_file_name"
    t.string   "icon_content_type", :limit => 30
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
  end

  create_table "changes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "priority_id"
    t.integer  "new_priority_id"
    t.string   "type"
    t.string   "status"
    t.integer  "yes_votes",             :default => 0
    t.integer  "no_votes",              :default => 0
    t.datetime "sent_at"
    t.datetime "approved_at"
    t.datetime "declined_at"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",              :default => 0
    t.integer  "cost"
    t.integer  "estimated_votes_count", :default => 0
    t.integer  "votes_count",           :default => 0
    t.boolean  "is_endorsers",          :default => true
    t.boolean  "is_opposers",           :default => true
    t.boolean  "is_flip",               :default => false
  end

  add_index "changes", ["new_priority_id"], :name => "changes_new_priority_id_index"
  add_index "changes", ["priority_id"], :name => "changes_priority_id_index"
  add_index "changes", ["status"], :name => "changes_status_index"
  add_index "changes", ["type"], :name => "changes_type_index"
  add_index "changes", ["user_id"], :name => "changes_user_id_index"

  create_table "client_applications", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "support_url"
    t.string   "callback_url"
    t.string   "key",          :limit => 50
    t.string   "secret",       :limit => 50
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "client_applications", ["key"], :name => "index_client_applications_on_key", :unique => true

  create_table "color_schemes", :force => true do |t|
    t.string   "nav_background",                :limit => 6,  :default => "f0f0f0"
    t.string   "nav_text",                      :limit => 6,  :default => "000000"
    t.string   "nav_selected_background",       :limit => 6,  :default => "dddddd"
    t.string   "nav_selected_text",             :limit => 6,  :default => "000000"
    t.string   "nav_hover_background",          :limit => 6,  :default => "13499b"
    t.string   "nav_hover_text",                :limit => 6,  :default => "ffffff"
    t.string   "background",                    :limit => 6,  :default => "ffffff"
    t.string   "box",                           :limit => 6,  :default => "f0f0f0"
    t.string   "text",                          :limit => 6,  :default => "444444"
    t.string   "link",                          :limit => 6,  :default => "13499b"
    t.string   "heading",                       :limit => 6,  :default => "000000"
    t.string   "sub_heading",                   :limit => 6,  :default => "999999"
    t.string   "greyed_out",                    :limit => 6,  :default => "999999"
    t.string   "border",                        :limit => 6,  :default => "dddddd"
    t.string   "error",                         :limit => 6,  :default => "bc0000"
    t.string   "error_text",                    :limit => 6,  :default => "ffffff"
    t.string   "down",                          :limit => 6,  :default => "bc0000"
    t.string   "up",                            :limit => 6,  :default => "009933"
    t.string   "action_button",                 :limit => 6,  :default => "ffff99"
    t.string   "action_button_border",          :limit => 6,  :default => "ffcc00"
    t.string   "endorsed_button",               :limit => 6,  :default => "009933"
    t.string   "endorsed_button_text",          :limit => 6,  :default => "ffffff"
    t.string   "opposed_button",                :limit => 6,  :default => "bc0000"
    t.string   "opposed_button_text",           :limit => 6,  :default => "ffffff"
    t.string   "compromised_button",            :limit => 6,  :default => "ffcc00"
    t.string   "compromised_button_text",       :limit => 6,  :default => "ffffff"
    t.string   "grey_button",                   :limit => 6,  :default => "f0f0f0"
    t.string   "grey_button_border",            :limit => 6,  :default => "cccccc"
    t.string   "fonts",                         :limit => 50, :default => "Arial, Helvetica, sans-serif"
    t.boolean  "background_tiled",                            :default => false
    t.string   "main",                          :limit => 6,  :default => "FFFFFF"
    t.string   "comments",                      :limit => 6,  :default => "F0F0F0"
    t.string   "comments_text",                 :limit => 6,  :default => "444444"
    t.string   "input",                         :limit => 6,  :default => "444444"
    t.string   "box_text",                      :limit => 6,  :default => "444444"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_featured",                                 :default => false
    t.string   "name",                          :limit => 60
    t.string   "footer",                        :limit => 6
    t.string   "footer_text",                   :limit => 6
    t.string   "grey_button_text",              :limit => 6
    t.string   "action_button_text",            :limit => 6
    t.string   "background_image_file_name"
    t.string   "background_image_content_type"
    t.integer  "background_image_file_size"
    t.datetime "background_image_updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "activity_id"
    t.integer  "user_id"
    t.string   "status"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_endorser",   :default => false
    t.string   "ip_address"
    t.string   "user_agent"
    t.string   "referrer"
    t.boolean  "is_opposer",    :default => false
    t.text     "content_html"
    t.integer  "flags_count",   :default => 0
    t.integer  "category_id"
    t.string   "category_name", :default => "no cat"
    t.integer  "partner_id"
  end

  add_index "comments", ["activity_id"], :name => "comments_activity_id"
  add_index "comments", ["status", "activity_id"], :name => "index_comments_on_status_and_activity_id"
  add_index "comments", ["status"], :name => "comments_status"
  add_index "comments", ["user_id"], :name => "comments_user_id"

  create_table "constituents", :force => true do |t|
    t.integer  "legislator_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "constituents", ["legislator_id", "user_id"], :name => "index_constituents_on_legislator_id_and_user_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "document_qualities", :force => true do |t|
    t.integer  "user_id"
    t.integer  "document_id"
    t.integer  "value",       :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "document_qualities", ["document_id"], :name => "index_document_qualities_on_document_id"
  add_index "document_qualities", ["user_id"], :name => "index_document_qualities_on_user_id"

  create_table "document_revisions", :force => true do |t|
    t.integer  "document_id"
    t.integer  "user_id"
    t.integer  "value",                       :default => 0, :null => false
    t.string   "status",       :limit => 30
    t.string   "name",         :limit => 60
    t.string   "ip_address",   :limit => 16
    t.string   "user_agent",   :limit => 150
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "content"
    t.text     "content_diff"
    t.integer  "word_count",                  :default => 0
    t.text     "content_html"
  end

  add_index "document_revisions", ["document_id"], :name => "index_document_revisions_on_document_id"
  add_index "document_revisions", ["status"], :name => "index_document_revisions_on_status"
  add_index "document_revisions", ["user_id"], :name => "index_document_revisions_on_user_id"

  create_table "documents", :force => true do |t|
    t.integer  "revision_id"
    t.integer  "priority_id"
    t.integer  "user_id"
    t.integer  "value",                                  :default => 0
    t.string   "status",                   :limit => 20
    t.string   "name",                     :limit => 60
    t.string   "cached_issue_list"
    t.string   "author_sentence"
    t.integer  "revisions_count",                        :default => 0
    t.integer  "helpful_count",                          :default => 0
    t.integer  "unhelpful_count",                        :default => 0
    t.integer  "discussions_count",                      :default => 0
    t.integer  "endorser_helpful_count",                 :default => 0
    t.integer  "opposer_helpful_count",                  :default => 0
    t.integer  "neutral_helpful_count",                  :default => 0
    t.integer  "endorser_unhelpful_count",               :default => 0
    t.integer  "opposer_unhelpful_count",                :default => 0
    t.integer  "neutral_unhelpful_count",                :default => 0
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "content"
    t.integer  "word_count",                             :default => 0
    t.text     "content_html"
    t.float    "score",                                  :default => 0.0
    t.float    "endorser_score",                         :default => 0.0
    t.float    "opposer_score",                          :default => 0.0
    t.float    "neutral_score",                          :default => 0.0
    t.integer  "partner_id"
    t.integer  "flags_count",                            :default => 0
  end

  add_index "documents", ["priority_id"], :name => "index_documents_on_priority_id"
  add_index "documents", ["revision_id"], :name => "index_documents_on_revision_id"
  add_index "documents", ["status"], :name => "index_documents_on_status"
  add_index "documents", ["user_id"], :name => "index_documents_on_user_id"

  create_table "endorsements", :force => true do |t|
    t.string   "status",      :limit => 50
    t.integer  "position"
    t.integer  "partner_id"
    t.integer  "priority_id"
    t.integer  "user_id"
    t.string   "ip_address",  :limit => 16
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "referral_id"
    t.integer  "value",                     :default => 1
    t.integer  "score",                     :default => 0
  end

  add_index "endorsements", ["partner_id"], :name => "endorsements_partner_id_index"
  add_index "endorsements", ["position"], :name => "position"
  add_index "endorsements", ["priority_id"], :name => "endorsements_priority_id_index"
  add_index "endorsements", ["status", "priority_id", "user_id", "value"], :name => "endorsements_status_pid_uid"
  add_index "endorsements", ["status"], :name => "endorsements_status_index"
  add_index "endorsements", ["user_id"], :name => "endorsements_user_id_index"
  add_index "endorsements", ["value"], :name => "value"

  create_table "facebook_templates", :force => true do |t|
    t.string "template_name", :null => false
    t.string "content_hash",  :null => false
    t.string "bundle_id"
  end

  add_index "facebook_templates", ["template_name"], :name => "index_facebook_templates_on_template_name", :unique => true

  create_table "feeds", :force => true do |t|
    t.string   "name"
    t.string   "website_link"
    t.string   "feed_link"
    t.string   "cached_issue_list"
    t.datetime "crawled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "following_discussions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "activity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "followings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "other_user_id"
    t.integer  "value",         :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "followings", ["other_user_id"], :name => "followings_other_user_id_index"
  add_index "followings", ["user_id"], :name => "followings_user_id_index"

  create_table "governments", :force => true do |t|
    t.string   "status",                         :limit => 30
    t.string   "short_name",                     :limit => 20
    t.string   "domain_name",                    :limit => 60
    t.string   "layout",                         :limit => 20
    t.string   "name",                           :limit => 60
    t.string   "tagline",                        :limit => 100
    t.string   "email",                          :limit => 100
    t.boolean  "is_public",                                     :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "db_name",                        :limit => 20
    t.integer  "official_user_id"
    t.string   "official_user_short_name",       :limit => 25
    t.string   "target",                         :limit => 30
    t.boolean  "is_tags",                                       :default => true
    t.boolean  "is_facebook",                                   :default => true
    t.boolean  "is_legislators",                                :default => false
    t.string   "admin_name",                     :limit => 60
    t.string   "admin_email",                    :limit => 100
    t.string   "google_analytics_code",          :limit => 15
    t.string   "quantcast_code",                 :limit => 20
    t.string   "tags_name",                      :limit => 20,  :default => "Category"
    t.string   "briefing_name",                  :limit => 20,  :default => "Briefing Room"
    t.string   "currency_name",                  :limit => 30,  :default => "political capital"
    t.string   "currency_short_name",            :limit => 3,   :default => "pc"
    t.string   "homepage",                       :limit => 20,  :default => "top"
    t.integer  "priorities_count",                              :default => 0
    t.integer  "points_count",                                  :default => 0
    t.integer  "documents_count",                               :default => 0
    t.integer  "users_count",                                   :default => 0
    t.integer  "contributors_count",                            :default => 0
    t.integer  "partners_count",                                :default => 0
    t.integer  "official_user_priorities_count",                :default => 0
    t.integer  "endorsements_count",                            :default => 0
    t.integer  "picture_id"
    t.integer  "color_scheme_id",                               :default => 1
    t.string   "mission",                        :limit => 200
    t.string   "prompt",                         :limit => 100
    t.integer  "buddy_icon_id"
    t.integer  "fav_icon_id"
    t.boolean  "is_suppress_empty_priorities",                  :default => false
    t.string   "tags_page",                      :limit => 20,  :default => "list"
    t.string   "facebook_api_key",               :limit => 32
    t.string   "facebook_secret_key",            :limit => 32
    t.string   "windows_appid",                  :limit => 32
    t.string   "windows_secret_key",             :limit => 32
    t.string   "yahoo_appid",                    :limit => 40
    t.string   "yahoo_secret_key",               :limit => 32
    t.boolean  "is_twitter",                                    :default => true
    t.string   "twitter_key",                    :limit => 46
    t.string   "twitter_secret_key",             :limit => 46
    t.string   "language_code",                  :limit => 2,   :default => "en"
    t.string   "password",                       :limit => 40
    t.string   "logo_file_name"
    t.string   "logo_content_type",              :limit => 30
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "buddy_icon_file_name"
    t.string   "buddy_icon_content_type",        :limit => 30
    t.integer  "buddy_icon_file_size"
    t.datetime "buddy_icon_updated_at"
    t.string   "fav_icon_file_name"
    t.string   "fav_icon_content_type",          :limit => 30
    t.integer  "fav_icon_file_size"
    t.datetime "fav_icon_updated_at"
    t.boolean  "google_login_enabled",                          :default => false
    t.string   "default_tags_checkbox"
    t.text     "message_to_users"
  end

  add_index "governments", ["domain_name"], :name => "index_governments_on_domain_name"
  add_index "governments", ["short_name"], :name => "index_governments_on_short_name"

  create_table "legislators", :force => true do |t|
    t.string   "name",               :limit => 100
    t.string   "fullname",           :limit => 100
    t.string   "nickname",           :limit => 30
    t.string   "title",              :limit => 10
    t.string   "firstname",          :limit => 60
    t.string   "middlename",         :limit => 20
    t.string   "lastname",           :limit => 60
    t.string   "name_suffix",        :limit => 5
    t.string   "gender",             :limit => 1
    t.string   "congress_office",    :limit => 200
    t.string   "party",              :limit => 1
    t.string   "state",              :limit => 2
    t.string   "district",           :limit => 15
    t.string   "senate_class",       :limit => 10
    t.boolean  "in_office",                         :default => true
    t.integer  "govtrack_id"
    t.integer  "votesmart_id"
    t.string   "fec_id",             :limit => 10
    t.string   "crp_id",             :limit => 10
    t.string   "bioguide_id",        :limit => 10
    t.string   "phone",              :limit => 20
    t.string   "fax",                :limit => 20
    t.string   "email",              :limit => 80
    t.string   "webform",            :limit => 100
    t.string   "website",            :limit => 100
    t.string   "twitter_id",         :limit => 20
    t.string   "congresspedia_url",  :limit => 100
    t.string   "youtube_url",        :limit => 50
    t.integer  "constituents_count",                :default => 0
    t.datetime "last_crawled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "short_name",         :limit => 30
  end

  add_index "legislators", ["govtrack_id"], :name => "index_legislators_on_govtrack_id"
  add_index "legislators", ["name"], :name => "index_legislators_on_name"
  add_index "legislators", ["short_name"], :name => "index_legislators_on_short_name"
  add_index "legislators", ["user_id"], :name => "index_legislators_on_user_id"

  create_table "letters", :force => true do |t|
    t.integer  "user_id"
    t.string   "type",       :limit => 60
    t.boolean  "is_public"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.string   "type",         :limit => 60
    t.string   "status",       :limit => 20
    t.string   "title",        :limit => 60
    t.text     "content"
    t.datetime "sent_at"
    t.datetime "read_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.text     "content_html"
  end

  add_index "messages", ["recipient_id"], :name => "messages_recipient_id_index"
  add_index "messages", ["sender_id"], :name => "messages_sender_id_index"
  add_index "messages", ["status"], :name => "messages_status_index"
  add_index "messages", ["type"], :name => "messages_type_index"

  create_table "notifications", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.string   "status",          :limit => 20
    t.string   "type",            :limit => 60
    t.integer  "notifiable_id"
    t.string   "notifiable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "sent_at"
    t.datetime "read_at"
    t.datetime "processed_at"
    t.datetime "deleted_at"
  end

  add_index "notifications", ["notifiable_type", "notifiable_id"], :name => "index_notifications_on_notifiable_type_and_notifiable_id"
  add_index "notifications", ["recipient_id"], :name => "index_notifications_on_recipient_id"
  add_index "notifications", ["sender_id"], :name => "index_notifications_on_sender_id"
  add_index "notifications", ["status", "type"], :name => "index_notifications_on_status_and_type"

  create_table "pages", :force => true do |t|
    t.string   "name",       :limit => 100
    t.string   "short_name", :limit => 30
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "link_name",  :limit => 60
  end

  create_table "partners", :force => true do |t|
    t.string   "name",                       :limit => 60
    t.string   "short_name",                 :limit => 20
    t.integer  "picture_id"
    t.integer  "is_optin",                   :limit => 1,   :default => 0,         :null => false
    t.string   "optin_text",                 :limit => 60
    t.string   "privacy_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "is_active",                  :limit => 1,   :default => 1,         :null => false
    t.string   "status",                                    :default => "passive"
    t.integer  "users_count",                               :default => 0
    t.string   "website"
    t.datetime "deleted_at"
    t.string   "ip_address",                 :limit => 16
    t.boolean  "is_daily_summary",                          :default => true
    t.string   "unsubscribe_url"
    t.string   "subscribe_url"
    t.string   "logo_file_name"
    t.string   "logo_content_type",          :limit => 30
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "default_tags"
    t.string   "custom_tag_checkbox"
    t.string   "custom_tag_dropdown_1"
    t.string   "custom_tag_dropdown_2"
    t.string   "name_variations_data",       :limit => 350
    t.boolean  "geoblocking_enabled",                       :default => false
    t.string   "geoblocking_open_countries",                :default => ""
    t.string   "default_locale"
    t.integer  "iso_country_id"
  end

  add_index "partners", ["short_name"], :name => "short_name"
  add_index "partners", ["status"], :name => "status"

  create_table "pictures", :force => true do |t|
    t.string   "name",         :limit => 200
    t.integer  "height",       :limit => 8
    t.integer  "width",        :limit => 8
    t.string   "content_type", :limit => 100
    t.binary   "data",         :limit => 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "point_qualities", :force => true do |t|
    t.integer  "user_id"
    t.integer  "point_id"
    t.boolean  "value",      :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "point_qualities", ["point_id"], :name => "point_id"
  add_index "point_qualities", ["user_id", "point_id"], :name => "user_and_point_id"
  add_index "point_qualities", ["user_id"], :name => "user_id"

  create_table "points", :force => true do |t|
    t.integer  "revision_id"
    t.integer  "priority_id"
    t.integer  "other_priority_id"
    t.integer  "user_id"
    t.integer  "value",                                   :default => 0
    t.integer  "revisions_count",                         :default => 0
    t.string   "status",                   :limit => 50
    t.string   "name",                     :limit => 122
    t.text     "content"
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "website"
    t.string   "author_sentence"
    t.integer  "helpful_count",                           :default => 0
    t.integer  "unhelpful_count",                         :default => 0
    t.integer  "discussions_count",                       :default => 0
    t.integer  "endorser_helpful_count",                  :default => 0
    t.integer  "opposer_helpful_count",                   :default => 0
    t.integer  "endorser_unhelpful_count",                :default => 0
    t.integer  "opposer_unhelpful_count",                 :default => 0
    t.integer  "neutral_helpful_count",                   :default => 0
    t.integer  "neutral_unhelpful_count",                 :default => 0
    t.float    "score",                                   :default => 0.0
    t.float    "endorser_score",                          :default => 0.0
    t.float    "opposer_score",                           :default => 0.0
    t.float    "neutral_score",                           :default => 0.0
    t.text     "content_html"
    t.integer  "partner_id"
    t.integer  "flags_count",                             :default => 0
    t.string   "user_agent",               :limit => 200
    t.string   "ip_address"
  end

  add_index "points", ["other_priority_id"], :name => "index_points_on_other_priority_id"
  add_index "points", ["priority_id"], :name => "index_points_on_priority_id"
  add_index "points", ["revision_id"], :name => "index_points_on_revision_id"
  add_index "points", ["status"], :name => "index_points_on_status"
  add_index "points", ["user_id"], :name => "index_points_on_user_id"

  create_table "portlet_containers", :force => true do |t|
    t.string   "title"
    t.integer  "weight"
    t.integer  "user_id"
    t.boolean  "default_admin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "partner_id"
  end

  add_index "portlet_containers", ["user_id"], :name => "index_portlet_containers_on_user_id"

  create_table "portlet_positions", :force => true do |t|
    t.integer  "portlet_id"
    t.integer  "css_column"
    t.integer  "css_position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "portlet_positions", ["portlet_id"], :name => "index_portlet_positions_on_portlet_id"

  create_table "portlet_template_categories", :force => true do |t|
    t.string   "name"
    t.integer  "weight"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "partner_id"
  end

  create_table "portlet_templates", :force => true do |t|
    t.string   "name"
    t.integer  "portlet_template_category_id"
    t.string   "locals_data_function"
    t.string   "partial_name"
    t.text     "description"
    t.integer  "weight"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "column_count",                 :default => 1
    t.boolean  "caching_disabled",             :default => false
    t.integer  "item_limit"
  end

  add_index "portlet_templates", ["portlet_template_category_id"], :name => "index_portlet_templates_on_portlet_template_category_id"

  create_table "portlets", :force => true do |t|
    t.integer  "portlet_template_id"
    t.integer  "portlet_container_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "portlets", ["portlet_container_id"], :name => "index_portlets_on_portlet_container_id"
  add_index "portlets", ["portlet_template_id"], :name => "index_portlets_on_portlet_template_id"

  create_table "priorities", :force => true do |t|
    t.integer  "position",                                :default => 0,     :null => false
    t.integer  "user_id"
    t.string   "name",                     :limit => 250
    t.integer  "endorsements_count",                      :default => 0,     :null => false
    t.string   "status",                   :limit => 50
    t.string   "ip_address",               :limit => 16
    t.datetime "deleted_at"
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position_1hr",                            :default => 0,     :null => false
    t.integer  "position_24hr",                           :default => 0,     :null => false
    t.integer  "position_7days",                          :default => 0,     :null => false
    t.integer  "position_30days",                         :default => 0,     :null => false
    t.integer  "position_1hr_change",                     :default => 0,     :null => false
    t.integer  "position_24hr_change",                    :default => 0,     :null => false
    t.integer  "position_7days_change",                   :default => 0,     :null => false
    t.integer  "position_30days_change",                  :default => 0,     :null => false
    t.integer  "change_id"
    t.string   "cached_issue_list"
    t.integer  "up_endorsements_count",                   :default => 0
    t.integer  "down_endorsements_count",                 :default => 0
    t.integer  "points_count",                            :default => 0
    t.integer  "up_points_count",                         :default => 0
    t.integer  "down_points_count",                       :default => 0
    t.integer  "neutral_points_count",                    :default => 0
    t.integer  "discussions_count",                       :default => 0
    t.integer  "relationships_count",                     :default => 0
    t.integer  "changes_count",                           :default => 0
    t.integer  "official_status",                         :default => 0
    t.integer  "official_value",                          :default => 0
    t.datetime "status_changed_at"
    t.integer  "score",                                   :default => 0
    t.integer  "up_documents_count",                      :default => 0
    t.integer  "down_documents_count",                    :default => 0
    t.integer  "neutral_documents_count",                 :default => 0
    t.integer  "documents_count",                         :default => 0
    t.string   "short_url",                :limit => 20
    t.boolean  "is_controversial",                        :default => false
    t.integer  "trending_score",                          :default => 0
    t.integer  "controversial_score",                     :default => 0
    t.string   "external_info_1"
    t.string   "external_info_2"
    t.string   "external_info_3"
    t.string   "external_link"
    t.string   "external_presenter"
    t.string   "external_id"
    t.string   "external_name"
    t.integer  "partner_id"
    t.integer  "flags_count",                             :default => 0
    t.integer  "category_id"
    t.string   "user_agent",               :limit => 200
    t.integer  "position_endorsed_24hr"
    t.integer  "position_endorsed_7days"
    t.integer  "position_endorsed_30days"
    t.text     "finished_status_message"
  end

  add_index "priorities", ["category_id"], :name => "index_priorities_on_category_id"
  add_index "priorities", ["official_status"], :name => "index_priorities_on_official_status"
  add_index "priorities", ["official_value"], :name => "index_priorities_on_official_value"
  add_index "priorities", ["position"], :name => "priorities_position_index"
  add_index "priorities", ["status"], :name => "priorities_status_index"
  add_index "priorities", ["trending_score"], :name => "index_priorities_on_trending_score"
  add_index "priorities", ["user_id"], :name => "priorities_user_id_index"

  create_table "priority_charts", :force => true do |t|
    t.integer  "priority_id"
    t.integer  "date_year"
    t.integer  "date_month"
    t.integer  "date_day"
    t.integer  "position"
    t.integer  "up_count"
    t.integer  "down_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "volume_count"
    t.float    "change_percent", :default => 0.0
    t.integer  "change",         :default => 0
  end

  add_index "priority_charts", ["date_year", "date_month", "date_day"], :name => "priority_chart_date_index"
  add_index "priority_charts", ["priority_id"], :name => "priority_chart_priority_index"

  create_table "priority_processes", :force => true do |t|
    t.integer  "external_id"
    t.string   "external_link"
    t.string   "external_name"
    t.integer  "process_type_id"
    t.integer  "sequence_number"
    t.integer  "stage_sequence_number"
    t.boolean  "root_node"
    t.integer  "parent_id"
    t.integer  "priority_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "archived",              :default => false
  end

  add_index "priority_processes", ["process_type_id"], :name => "index_priority_processes_on_process_type_id"

  create_table "process_discussions", :force => true do |t|
    t.datetime "meeting_date"
    t.string   "external_id"
    t.string   "external_link"
    t.integer  "stage_sequence_number"
    t.integer  "sequence_number"
    t.datetime "to_time"
    t.datetime "from_time"
    t.string   "transcript_url"
    t.string   "listen_url"
    t.string   "meeting_info"
    t.string   "meeting_type"
    t.string   "meeting_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "priority_process_id"
    t.boolean  "processed_for_speech_videos"
    t.boolean  "published"
    t.boolean  "in_video_processing",         :default => false
    t.boolean  "video_processing_complete",   :default => false
    t.boolean  "has_modified_durations",      :default => false
  end

  add_index "process_discussions", ["priority_process_id"], :name => "index_process_discussions_on_priority_process_id"
  add_index "process_discussions", ["transcript_url"], :name => "index_process_discussions_on_transcript_url"

  create_table "process_document_elements", :force => true do |t|
    t.integer  "sequence_number"
    t.integer  "process_document_id"
    t.integer  "parent_id"
    t.binary   "content",             :limit => 2147483647
    t.binary   "content_text_only",   :limit => 2147483647
    t.string   "content_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "content_type"
    t.boolean  "original_version"
  end

  add_index "process_document_elements", ["process_document_id"], :name => "index_process_document_elements_on_process_document_id"
  add_index "process_document_elements", ["user_id"], :name => "index_process_document_elements_on_user_id"

  create_table "process_document_states", :force => true do |t|
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "process_document_types", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "template_name"
    t.string   "process_document_type"
  end

  create_table "process_documents", :force => true do |t|
    t.integer  "process_document_state_id"
    t.integer  "process_document_type_id"
    t.datetime "voting_close_time"
    t.boolean  "published"
    t.string   "external_name"
    t.string   "external_author"
    t.string   "external_state"
    t.datetime "external_creation_date"
    t.string   "external_link"
    t.datetime "external_date"
    t.string   "external_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "process_document_frozen"
    t.integer  "user_id"
    t.integer  "priority_process_id"
    t.integer  "process_document_id"
    t.boolean  "original_version"
    t.integer  "stage_sequence_number"
    t.integer  "sequence_number"
    t.string   "external_type"
  end

  add_index "process_documents", ["priority_process_id"], :name => "index_process_documents_on_priority_process_id"
  add_index "process_documents", ["process_document_state_id"], :name => "index_process_documents_on_process_document_state_id"
  add_index "process_documents", ["process_document_type_id"], :name => "index_process_documents_on_process_document_type_id"

  create_table "process_speech_master_videos", :force => true do |t|
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "in_processing", :default => false
    t.boolean  "published",     :default => false
  end

  add_index "process_speech_master_videos", ["url"], :name => "index_process_speech_master_videos_on_url", :unique => true

  create_table "process_speech_videos", :force => true do |t|
    t.integer  "process_discussion_id"
    t.string   "title"
    t.datetime "to_time"
    t.datetime "from_time"
    t.integer  "sequence_number"
    t.integer  "parent_id"
    t.integer  "process_speech_master_video_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.time     "start_offset"
    t.time     "duration"
    t.boolean  "in_processing",                  :default => false
    t.boolean  "published",                      :default => false
    t.integer  "modified_duration_s"
    t.boolean  "has_checked_duration",           :default => false
  end

  add_index "process_speech_videos", ["process_discussion_id"], :name => "index_process_speech_videos_on_process_discussion_id"
  add_index "process_speech_videos", ["process_speech_master_video_id"], :name => "index_process_speech_videos_on_process_speech_master_video_id"

  create_table "process_types", :force => true do |t|
    t.string   "process_type"
    t.string   "template_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", :force => true do |t|
    t.integer  "user_id"
    t.text     "bio"
    t.text     "bio_html"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id"

  create_table "rankings", :force => true do |t|
    t.integer  "priority_id"
    t.integer  "version",            :default => 0
    t.integer  "position"
    t.integer  "endorsements_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "partner_id"
  end

  add_index "rankings", ["created_at"], :name => "rankings_created_at_index"
  add_index "rankings", ["priority_id"], :name => "rankings_priority_id"
  add_index "rankings", ["version"], :name => "rankings_version_index"

  create_table "ratings", :force => true do |t|
    t.integer  "rating",                      :default => 0
    t.datetime "created_at",                                  :null => false
    t.integer  "rateable_id",                 :default => 0,  :null => false
    t.integer  "user_id",                     :default => 0,  :null => false
    t.string   "rateable_type", :limit => 50, :default => "", :null => false
  end

  add_index "ratings", ["user_id"], :name => "fk_ratings_user"

  create_table "relationships", :force => true do |t|
    t.integer  "priority_id"
    t.integer  "other_priority_id"
    t.string   "type",              :limit => 70
    t.integer  "percentage"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationships", ["other_priority_id"], :name => "relationships_other_priority_index"
  add_index "relationships", ["priority_id"], :name => "relationships_priority_index"
  add_index "relationships", ["type"], :name => "relationships_type_index"

  create_table "revisions", :force => true do |t|
    t.integer  "point_id"
    t.integer  "user_id"
    t.integer  "value",                            :default => 0, :null => false
    t.string   "status",            :limit => 50
    t.string   "name",              :limit => 60
    t.text     "content"
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip_address",        :limit => 16
    t.string   "user_agent",        :limit => 150
    t.string   "website",           :limit => 100
    t.text     "content_diff"
    t.integer  "other_priority_id"
    t.text     "content_html"
  end

  add_index "revisions", ["other_priority_id"], :name => "index_revisions_on_other_priority_id"
  add_index "revisions", ["point_id"], :name => "index_revisions_on_point_id"
  add_index "revisions", ["status"], :name => "index_revisions_on_status"
  add_index "revisions", ["user_id"], :name => "index_revisions_on_user_id"

  create_table "shown_ads", :force => true do |t|
    t.integer  "ad_id"
    t.integer  "user_id"
    t.integer  "value",                     :default => 0
    t.string   "ip_address", :limit => 16
    t.string   "user_agent", :limit => 100
    t.string   "referrer",   :limit => 100
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "seen_count",                :default => 1
  end

  add_index "shown_ads", ["ad_id", "user_id"], :name => "ad_id"

  create_table "signups", :force => true do |t|
    t.integer  "partner_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip_address", :limit => 16
  end

  add_index "signups", ["partner_id"], :name => "signups_partner_id"
  add_index "signups", ["user_id"], :name => "signups_user_id"

  create_table "simple_captcha_data", :force => true do |t|
    t.string   "key",        :limit => 40
    t.string   "value",      :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "simple_captcha_data", ["key"], :name => "index_simple_captcha_data_on_key"

  create_table "tag_subscriptions", :id => false, :force => true do |t|
    t.integer "user_id", :null => false
    t.integer "tag_id",  :null => false
  end

  add_index "tag_subscriptions", ["tag_id"], :name => "index_tag_subscriptions_on_tag_id"
  add_index "tag_subscriptions", ["user_id"], :name => "index_tag_subscriptions_on_user_id"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type",   :limit => 50
    t.string   "taggable_type", :limit => 50
    t.string   "context",       :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string   "name",                      :limit => 60
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "top_priority_id"
    t.integer  "up_endorsers_count",                       :default => 0
    t.integer  "down_endorsers_count",                     :default => 0
    t.integer  "controversial_priority_id"
    t.integer  "rising_priority_id"
    t.integer  "official_priority_id"
    t.integer  "webpages_count",                           :default => 0
    t.integer  "priorities_count",                         :default => 0
    t.integer  "feeds_count",                              :default => 0
    t.string   "title",                     :limit => 60
    t.string   "description",               :limit => 200
    t.integer  "discussions_count",                        :default => 0
    t.integer  "points_count",                             :default => 0
    t.integer  "documents_count",                          :default => 0
    t.string   "prompt",                    :limit => 100
    t.string   "slug",                      :limit => 60
    t.integer  "partner_id"
    t.integer  "tag_type"
  end

  add_index "tags", ["slug"], :name => "index_tags_on_slug"
  add_index "tags", ["top_priority_id"], :name => "tag_top_priority_id_index"

  create_table "tr8n_glossary", :force => true do |t|
    t.string   "keyword"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_glossary", ["keyword"], :name => "index_tr8n_glossary_on_keyword"

  create_table "tr8n_ip_locations", :force => true do |t|
    t.integer  "low",        :limit => 8
    t.integer  "high",       :limit => 8
    t.string   "registry",   :limit => 20
    t.date     "assigned"
    t.string   "ctry",       :limit => 2
    t.string   "cntry",      :limit => 3
    t.string   "country",    :limit => 80
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_ip_locations", ["high"], :name => "index_tr8n_ip_locations_on_high"
  add_index "tr8n_ip_locations", ["low"], :name => "index_tr8n_ip_locations_on_low"

  create_table "tr8n_iso_countries", :force => true do |t|
    t.string   "code",                 :null => false
    t.string   "country_english_name", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_iso_countries", ["code"], :name => "index_tr8n_iso_countries_on_code"

  create_table "tr8n_iso_countries_tr8n_languages", :id => false, :force => true do |t|
    t.integer "tr8n_iso_country_id"
    t.integer "tr8n_language_id"
  end

  create_table "tr8n_language_case_rules", :force => true do |t|
    t.integer  "language_case_id", :null => false
    t.integer  "language_id"
    t.integer  "translator_id"
    t.text     "definition",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  add_index "tr8n_language_case_rules", ["language_case_id"], :name => "tr8n_lcr_case_id"
  add_index "tr8n_language_case_rules", ["language_id"], :name => "tr8n_lcr_lang_id"
  add_index "tr8n_language_case_rules", ["translator_id"], :name => "tr8n_lcr_translator_id"

  create_table "tr8n_language_case_value_maps", :force => true do |t|
    t.string   "keyword",       :null => false
    t.integer  "language_id",   :null => false
    t.integer  "translator_id"
    t.text     "map"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "reported"
  end

  add_index "tr8n_language_case_value_maps", ["keyword", "language_id"], :name => "index_tr8n_language_case_value_maps_on_key_and_language_id"
  add_index "tr8n_language_case_value_maps", ["translator_id"], :name => "index_tr8n_language_case_value_maps_on_translator_id"

  create_table "tr8n_language_cases", :force => true do |t|
    t.integer  "language_id",   :null => false
    t.integer  "translator_id"
    t.string   "keyword"
    t.string   "latin_name"
    t.string   "native_name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "application"
  end

  add_index "tr8n_language_cases", ["language_id", "keyword"], :name => "index_tr8n_language_cases_on_language_id_and_keyword"
  add_index "tr8n_language_cases", ["language_id", "translator_id"], :name => "index_tr8n_language_cases_on_language_id_and_translator_id"
  add_index "tr8n_language_cases", ["language_id"], :name => "index_tr8n_language_cases_on_language_id"

  create_table "tr8n_language_forum_abuse_reports", :force => true do |t|
    t.integer  "language_id",               :null => false
    t.integer  "translator_id",             :null => false
    t.integer  "language_forum_message_id", :null => false
    t.string   "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_language_forum_abuse_reports", ["language_forum_message_id"], :name => "tr8n_forum_reports_message_id"
  add_index "tr8n_language_forum_abuse_reports", ["language_id", "translator_id"], :name => "tr8n_forum_reports_lang_id_translator_id"
  add_index "tr8n_language_forum_abuse_reports", ["language_id"], :name => "tr8n_forum_reports_lang_id"

  create_table "tr8n_language_forum_messages", :force => true do |t|
    t.integer  "language_id",             :null => false
    t.integer  "language_forum_topic_id", :null => false
    t.integer  "translator_id",           :null => false
    t.text     "message",                 :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_language_forum_messages", ["language_id", "language_forum_topic_id"], :name => "tr8n_forum_msgs_lang_id_topic_id"
  add_index "tr8n_language_forum_messages", ["language_id"], :name => "tr8n_forum_msgs_lang_id"
  add_index "tr8n_language_forum_messages", ["translator_id"], :name => "tr8n_forums_msgs_translator_id"

  create_table "tr8n_language_forum_topics", :force => true do |t|
    t.integer  "translator_id", :null => false
    t.integer  "language_id"
    t.text     "topic",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_language_forum_topics", ["language_id"], :name => "tr8n_forum_topics_lang_id"
  add_index "tr8n_language_forum_topics", ["translator_id"], :name => "tr8n_forum_topics_translator_id"

  create_table "tr8n_language_metrics", :force => true do |t|
    t.string   "type"
    t.integer  "language_id",                         :null => false
    t.date     "metric_date"
    t.integer  "user_count",           :default => 0
    t.integer  "translator_count",     :default => 0
    t.integer  "translation_count",    :default => 0
    t.integer  "key_count",            :default => 0
    t.integer  "locked_key_count",     :default => 0
    t.integer  "translated_key_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_language_metrics", ["created_at"], :name => "index_tr8n_language_metrics_on_created_at"
  add_index "tr8n_language_metrics", ["language_id"], :name => "index_tr8n_language_metrics_on_language_id"

  create_table "tr8n_language_rules", :force => true do |t|
    t.integer  "language_id",   :null => false
    t.integer  "translator_id"
    t.string   "type"
    t.text     "definition"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_language_rules", ["language_id", "translator_id"], :name => "index_tr8n_language_rules_on_language_id_and_translator_id"
  add_index "tr8n_language_rules", ["language_id"], :name => "index_tr8n_language_rules_on_language_id"

  create_table "tr8n_language_users", :force => true do |t|
    t.integer  "language_id",                      :null => false
    t.integer  "user_id",                          :null => false
    t.integer  "translator_id"
    t.boolean  "manager",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_language_users", ["created_at"], :name => "index_tr8n_language_users_on_created_at"
  add_index "tr8n_language_users", ["language_id", "translator_id"], :name => "index_tr8n_language_users_on_language_id_and_translator_id"
  add_index "tr8n_language_users", ["language_id", "user_id"], :name => "index_tr8n_language_users_on_language_id_and_user_id"
  add_index "tr8n_language_users", ["updated_at"], :name => "index_tr8n_language_users_on_updated_at"
  add_index "tr8n_language_users", ["user_id"], :name => "index_tr8n_language_users_on_user_id"

  create_table "tr8n_languages", :force => true do |t|
    t.string   "locale",                              :null => false
    t.string   "english_name",                        :null => false
    t.string   "native_name"
    t.boolean  "enabled"
    t.boolean  "right_to_left"
    t.integer  "completeness"
    t.integer  "fallback_language_id"
    t.text     "curse_words"
    t.integer  "featured_index",       :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "google_key"
    t.string   "facebook_key"
  end

  add_index "tr8n_languages", ["locale"], :name => "index_tr8n_languages_on_locale"

  create_table "tr8n_translation_domains", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "source_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_translation_domains", ["name"], :name => "index_tr8n_translation_domains_on_name", :unique => true

  create_table "tr8n_translation_key_comments", :force => true do |t|
    t.integer  "language_id",        :null => false
    t.integer  "translation_key_id", :null => false
    t.integer  "translator_id",      :null => false
    t.text     "message",            :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_translation_key_comments", ["language_id", "translation_key_id"], :name => "tr8n_tkey_msgs_lang_id_tkey_id"
  add_index "tr8n_translation_key_comments", ["language_id"], :name => "tr8n_tkey_msgs_lang_id"
  add_index "tr8n_translation_key_comments", ["translator_id"], :name => "tr8n_tkey_msgs_translator_id"

  create_table "tr8n_translation_key_locks", :force => true do |t|
    t.integer  "translation_key_id",                    :null => false
    t.integer  "language_id",                           :null => false
    t.integer  "translator_id"
    t.boolean  "locked",             :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_translation_key_locks", ["translation_key_id", "language_id"], :name => "tr8n_locks_key_id_lang_id"

  create_table "tr8n_translation_key_sources", :force => true do |t|
    t.integer  "translation_key_id",    :null => false
    t.integer  "translation_source_id", :null => false
    t.text     "details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_translation_key_sources", ["translation_key_id"], :name => "tr8n_trans_keys_key_id"
  add_index "tr8n_translation_key_sources", ["translation_source_id"], :name => "tr8n_trans_keys_source_id"

  create_table "tr8n_translation_keys", :force => true do |t|
    t.string   "key",                              :null => false
    t.text     "label",                            :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "verified_at"
    t.integer  "translation_count"
    t.boolean  "admin"
    t.string   "locale"
    t.integer  "level",             :default => 0
  end

  add_index "tr8n_translation_keys", ["key"], :name => "index_tr8n_translation_keys_on_key", :unique => true

  create_table "tr8n_translation_sources", :force => true do |t|
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "translation_domain_id"
  end

  add_index "tr8n_translation_sources", ["source"], :name => "tr8n_sources_source"

  create_table "tr8n_translation_votes", :force => true do |t|
    t.integer  "translation_id", :null => false
    t.integer  "translator_id",  :null => false
    t.integer  "vote",           :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_translation_votes", ["translation_id", "translator_id"], :name => "tr8n_trans_votes_trans_id_translator_id"
  add_index "tr8n_translation_votes", ["translator_id"], :name => "tr8n_trans_votes_translator_id"

  create_table "tr8n_translations", :force => true do |t|
    t.integer  "translation_key_id",                             :null => false
    t.integer  "language_id",                                    :null => false
    t.integer  "translator_id",                                  :null => false
    t.text     "label",                                          :null => false
    t.integer  "rank",                            :default => 0
    t.integer  "approved_by_id",     :limit => 8
    t.text     "rules"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_translations", ["created_at"], :name => "tr8n_trans_created_at"
  add_index "tr8n_translations", ["translation_key_id", "translator_id", "language_id"], :name => "tr8n_trans_key_id_translator_id_lang_id"
  add_index "tr8n_translations", ["translator_id"], :name => "r8n_trans_translator_id"

  create_table "tr8n_translator_following", :force => true do |t|
    t.integer  "translator_id"
    t.integer  "object_id"
    t.string   "object_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_translator_following", ["translator_id"], :name => "index_tr8n_translator_following_on_translator_id"

  create_table "tr8n_translator_logs", :force => true do |t|
    t.integer  "translator_id"
    t.integer  "user_id",       :limit => 8
    t.string   "action"
    t.integer  "action_level"
    t.string   "reason"
    t.string   "reference"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_translator_logs", ["created_at"], :name => "index_tr8n_translator_logs_on_created_at"
  add_index "tr8n_translator_logs", ["translator_id"], :name => "index_tr8n_translator_logs_on_translator_id"
  add_index "tr8n_translator_logs", ["user_id"], :name => "index_tr8n_translator_logs_on_user_id"

  create_table "tr8n_translator_metrics", :force => true do |t|
    t.integer  "translator_id",                                     :null => false
    t.integer  "language_id",           :limit => 8
    t.integer  "total_translations",                 :default => 0
    t.integer  "total_votes",                        :default => 0
    t.integer  "positive_votes",                     :default => 0
    t.integer  "negative_votes",                     :default => 0
    t.integer  "accepted_translations",              :default => 0
    t.integer  "rejected_translations",              :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_translator_metrics", ["created_at"], :name => "index_tr8n_translator_metrics_on_created_at"
  add_index "tr8n_translator_metrics", ["translator_id", "language_id"], :name => "index_tr8n_translator_metrics_on_translator_id_and_language_id"
  add_index "tr8n_translator_metrics", ["translator_id"], :name => "index_tr8n_translator_metrics_on_translator_id"

  create_table "tr8n_translator_reports", :force => true do |t|
    t.integer  "translator_id"
    t.string   "state"
    t.integer  "object_id"
    t.string   "object_type"
    t.string   "reason"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tr8n_translator_reports", ["translator_id"], :name => "index_tr8n_translator_reports_on_translator_id"

  create_table "tr8n_translators", :force => true do |t|
    t.integer  "user_id",                                 :null => false
    t.boolean  "inline_mode",          :default => false
    t.boolean  "blocked",              :default => false
    t.boolean  "reported",             :default => false
    t.integer  "fallback_language_id"
    t.integer  "rank",                 :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "gender"
    t.string   "email"
    t.string   "password"
    t.string   "mugshot"
    t.string   "link"
    t.string   "locale"
    t.integer  "level",                :default => 0
    t.boolean  "manager"
    t.string   "last_ip"
    t.string   "country_code"
  end

  add_index "tr8n_translators", ["created_at"], :name => "index_tr8n_translators_on_created_at"
  add_index "tr8n_translators", ["email", "password"], :name => "index_tr8n_translators_on_email_and_password"
  add_index "tr8n_translators", ["email"], :name => "index_tr8n_translators_on_email"
  add_index "tr8n_translators", ["user_id"], :name => "index_tr8n_translators_on_user_id"

  create_table "unsubscribes", :force => true do |t|
    t.integer  "user_id"
    t.string   "email"
    t.text     "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_comments_subscribed",      :default => false
    t.boolean  "is_votes_subscribed",         :default => false
    t.boolean  "is_newsletter_subscribed",    :default => false
    t.boolean  "is_point_changes_subscribed", :default => false
    t.boolean  "is_messages_subscribed",      :default => false
    t.boolean  "is_followers_subscribed",     :default => true
    t.boolean  "is_finished_subscribed",      :default => true
    t.boolean  "is_admin_subscribed",         :default => false
  end

  create_table "user_charts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "date_year"
    t.integer  "date_month"
    t.integer  "date_day"
    t.integer  "position"
    t.integer  "up_count"
    t.integer  "down_count"
    t.integer  "volume_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_charts", ["date_year", "date_month", "date_day"], :name => "user_chart_date_index"
  add_index "user_charts", ["user_id"], :name => "user_chart_user_index"

  create_table "user_contacts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "other_user_id"
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "following_id"
    t.integer  "facebook_uid"
    t.datetime "sent_at"
    t.datetime "accepted_at"
    t.boolean  "is_from_realname",               :default => false
    t.string   "status",           :limit => 30
  end

  add_index "user_contacts", ["email"], :name => "index_user_contacts_on_email"
  add_index "user_contacts", ["facebook_uid"], :name => "index_user_contacts_on_facebook_uid"
  add_index "user_contacts", ["following_id"], :name => "index_user_contacts_on_following_id"
  add_index "user_contacts", ["other_user_id"], :name => "index_user_contacts_on_other_user_id"
  add_index "user_contacts", ["status"], :name => "index_user_contacts_on_status"
  add_index "user_contacts", ["user_id"], :name => "user_contacts_user_id_index"

  create_table "user_rankings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "version",        :default => 0
    t.integer  "position"
    t.integer  "capitals_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_rankings", ["created_at"], :name => "rankings_created_at_index"
  add_index "user_rankings", ["user_id"], :name => "rankings_user_id"
  add_index "user_rankings", ["version"], :name => "rankings_version_index"

  create_table "users", :force => true do |t|
    t.string   "login",                        :limit => 40
    t.string   "email",                        :limit => 100
    t.string   "crypted_password",             :limit => 40
    t.string   "salt",                         :limit => 40
    t.string   "first_name",                   :limit => 100
    t.string   "last_name",                    :limit => 100
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "activated_at"
    t.string   "activation_code",              :limit => 60
    t.string   "remember_token",               :limit => 60
    t.datetime "remember_token_expires_at"
    t.integer  "picture_id"
    t.string   "status",                       :limit => 30,  :default => "passive"
    t.integer  "partner_id"
    t.datetime "deleted_at"
    t.string   "ip_address",                   :limit => 16
    t.datetime "loggedin_at"
    t.string   "zip",                          :limit => 10
    t.date     "birth_date"
    t.string   "twitter_login",                :limit => 15
    t.string   "website",                      :limit => 150
    t.boolean  "is_mergeable",                                :default => true
    t.integer  "referral_id"
    t.boolean  "is_subscribed",                               :default => true
    t.string   "user_agent",                   :limit => 200
    t.string   "referrer",                     :limit => 200
    t.boolean  "is_comments_subscribed",                      :default => true
    t.boolean  "is_votes_subscribed",                         :default => true
    t.boolean  "is_newsletter_subscribed",                    :default => true
    t.boolean  "is_tagger",                                   :default => false
    t.integer  "endorsements_count",                          :default => 0
    t.integer  "up_endorsements_count",                       :default => 0
    t.integer  "down_endorsements_count",                     :default => 0
    t.integer  "up_issues_count",                             :default => 0
    t.integer  "down_issues_count",                           :default => 0
    t.integer  "comments_count",                              :default => 0
    t.float    "score",                                       :default => 0.1
    t.boolean  "is_point_changes_subscribed",                 :default => true
    t.boolean  "is_messages_subscribed",                      :default => true
    t.integer  "capitals_count",                              :default => 0
    t.integer  "twitter_count",                               :default => 0
    t.integer  "followers_count",                             :default => 0
    t.integer  "followings_count",                            :default => 0
    t.integer  "ignorers_count",                              :default => 0
    t.integer  "ignorings_count",                             :default => 0
    t.integer  "position_24hr",                               :default => 0
    t.integer  "position_7days",                              :default => 0
    t.integer  "position_30days",                             :default => 0
    t.integer  "position_24hr_change",                        :default => 0
    t.integer  "position_7days_change",                       :default => 0
    t.integer  "position_30days_change",                      :default => 0
    t.integer  "position",                                    :default => 0
    t.boolean  "is_followers_subscribed",                     :default => true
    t.integer  "partner_referral_id"
    t.integer  "ads_count",                                   :default => 0
    t.integer  "changes_count",                               :default => 0
    t.string   "google_token",                 :limit => 30
    t.integer  "top_endorsement_id"
    t.boolean  "is_finished_subscribed",                      :default => true
    t.integer  "contacts_count",                              :default => 0
    t.integer  "contacts_members_count",                      :default => 0
    t.integer  "contacts_invited_count",                      :default => 0
    t.integer  "contacts_not_invited_count",                  :default => 0
    t.datetime "google_crawled_at"
    t.integer  "facebook_uid",                 :limit => 8
    t.string   "city",                         :limit => 80
    t.string   "state",                        :limit => 50
    t.integer  "documents_count",                             :default => 0
    t.integer  "document_revisions_count",                    :default => 0
    t.integer  "points_count",                                :default => 0
    t.float    "index_24hr_change",                           :default => 0.0
    t.float    "index_7days_change",                          :default => 0.0
    t.float    "index_30days_change",                         :default => 0.0
    t.integer  "received_notifications_count",                :default => 0
    t.integer  "unread_notifications_count",                  :default => 0
    t.string   "rss_code",                     :limit => 40
    t.integer  "point_revisions_count",                       :default => 0
    t.integer  "qualities_count",                             :default => 0
    t.integer  "constituents_count",                          :default => 0
    t.string   "address",                      :limit => 100
    t.integer  "warnings_count",                              :default => 0
    t.datetime "probation_at"
    t.datetime "suspended_at"
    t.integer  "referrals_count",                             :default => 0
    t.boolean  "is_admin",                                    :default => false
    t.integer  "twitter_id"
    t.string   "twitter_token",                :limit => 64
    t.string   "twitter_secret",               :limit => 64
    t.datetime "twitter_crawled_at"
    t.boolean  "is_admin_subscribed",                         :default => true
    t.string   "buddy_icon_file_name"
    t.string   "buddy_icon_content_type",      :limit => 30
    t.integer  "buddy_icon_file_size"
    t.datetime "buddy_icon_updated_at"
    t.boolean  "is_importing_contacts",                       :default => false
    t.integer  "imported_contacts_count",                     :default => 0
    t.integer  "facebook_id"
    t.boolean  "reports_enabled",                             :default => false
    t.boolean  "reports_discussions",                         :default => false
    t.boolean  "reports_questions",                           :default => false
    t.boolean  "reports_documents",                           :default => false
    t.integer  "reports_interval"
    t.datetime "last_sent_report"
    t.string   "geoblocking_open_countries",                  :default => ""
    t.string   "identifier_url"
    t.string   "age_group"
    t.string   "post_code"
    t.string   "my_gender"
  end

  add_index "users", ["facebook_uid"], :name => "index_users_on_facebook_uid"
  add_index "users", ["identifier_url"], :name => "index_users_on_identifier_url", :unique => true
  add_index "users", ["partner_id"], :name => "user_partner_id"
  add_index "users", ["rss_code"], :name => "index_users_on_rss_code"
  add_index "users", ["status"], :name => "status"
  add_index "users", ["twitter_id"], :name => "index_users_on_twitter_id"

  create_table "votes", :force => true do |t|
    t.integer  "change_id"
    t.integer  "user_id"
    t.string   "code"
    t.string   "status"
    t.datetime "voted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "value",      :default => 1
  end

  add_index "votes", ["change_id"], :name => "votes_change_id_index"
  add_index "votes", ["code"], :name => "votes_code_index"
  add_index "votes", ["status"], :name => "votes_status_index"
  add_index "votes", ["user_id"], :name => "votes_user_id_index"

  create_table "webpages", :force => true do |t|
    t.integer  "user_id"
    t.string   "status",            :limit => 20
    t.string   "url"
    t.string   "title"
    t.string   "description"
    t.datetime "crawled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content_type"
    t.string   "charset"
    t.string   "content_encoding"
    t.datetime "published_at"
    t.string   "cached_issue_list", :limit => 150
    t.integer  "feed_id"
    t.string   "domain",            :limit => 100
  end

  add_index "webpages", ["feed_id"], :name => "index_webpages_on_feed_id"
  add_index "webpages", ["status"], :name => "status"
  add_index "webpages", ["user_id"], :name => "webpages_user_id_index"

  create_table "wf_filters", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.text     "data"
    t.integer  "user_id"
    t.string   "model_class_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wf_filters", ["user_id"], :name => "index_wf_filters_on_user_id"

  create_table "widgets", :force => true do |t|
    t.integer  "user_id"
    t.string   "tag_id"
    t.string   "controller_name"
    t.string   "action_name"
    t.integer  "number",          :default => 5
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
