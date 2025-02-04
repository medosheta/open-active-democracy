class Priority < ActiveRecord::Base
  
  extend ActiveSupport::Memoizable
  
  include ActionView::Helpers::DateHelper

  acts_as_set_partner :table_name=>"priorities"

  if Government.current and Government.current.is_suppress_empty_priorities?
    scope :published, :conditions => "priorities.status = 'published' and priorities.position > 0 and endorsements_count > 0"
  else
    scope :published, :conditions => "priorities.status = 'published'"
  end

  scope :published, :conditions => "priorities.status = 'published'"
  scope :unpublished, :conditions => "priorities.status not in ('published','abusive')"

  scope :flagged, :conditions => "flags_count > 0"

  scope :alphabetical, :order => "priorities.name asc"

  scope :top_rank, :order => "priorities.score desc, priorities.position asc"

  scope :top_24hr, :conditions => "priorities.position_endorsed_24hr IS NOT NULL", :order => "priorities.position_endorsed_24hr asc"
  scope :top_7days, :conditions => "priorities.position_endorsed_7days IS NOT NULL", :order => "priorities.position_endorsed_7days asc"
  scope :top_30days, :conditions => "priorities.position_endorsed_30days IS NOT NULL", :order => "priorities.position_endorsed_30days asc"

  scope :not_top_rank, :conditions => "priorities.position > 25"
  scope :rising, :conditions => "priorities.trending_score > 0", :order => "priorities.trending_score desc"
  scope :falling, :conditions => "priorities.trending_score < 0", :order => "priorities.trending_score asc"
  scope :controversial, :conditions => "priorities.is_controversial = true", :order => "priorities.controversial_score desc"

  scope :rising_7days, :conditions => "priorities.position_7days_change > 0"
  scope :flat_7days, :conditions => "priorities.position_7days_change = 0"
  scope :falling_7days, :conditions => "priorities.position_7days_change < 0"
  scope :rising_30days, :conditions => "priorities.position_30days_change > 0"
  scope :flat_30days, :conditions => "priorities.position_30days_change = 0"
  scope :falling_30days, :conditions => "priorities.position_30days_change < 0"
  scope :rising_24hr, :conditions => "priorities.position_24hr_change > 0"
  scope :flat_24hr, :conditions => "priorities.position_24hr_change = 0"
  scope :falling_24hr, :conditions => "priorities.position_24hr_change < 0"
  
  scope :finished, :conditions => "priorities.official_status in (-2,-1,2)"
  
  scope :by_user_id, lambda{|user_id| {:conditions=>["user_id=?",user_id]}}
  scope :item_limit, lambda{|limit| {:limit=>limit}} 
  
  scope :alphabetical, :order => "priorities.name asc"
  scope :newest, :order => "priorities.published_at desc, priorities.created_at desc"
  scope :tagged, :conditions => "(priorities.cached_issue_list is not null and priorities.cached_issue_list <> '')"
  scope :untagged, :conditions => "(priorities.cached_issue_list is null or priorities.cached_issue_list = '')", :order => "priorities.endorsements_count desc, priorities.created_at desc"

  scope :by_most_recent_status_change, :order => "priorities.status_changed_at desc"
  
  scope :item_limit, lambda{|limit| {:limit=>limit}}  
  
  belongs_to :user
  belongs_to :partner
  belongs_to :category
  
  has_many :relationships, :dependent => :destroy
  has_many :incoming_relationships, :foreign_key => :other_priority_id, :class_name => "Relationship", :dependent => :destroy
  
  has_many :endorsements, :dependent => :destroy
  has_many :endorsers, :through => :endorsements, :conditions => "endorsements.status in ('active','inactive')", :source => :user, :class_name => "User"
  has_many :up_endorsers, :through => :endorsements, :conditions => "endorsements.status in ('active','inactive') and endorsements.value=1", :source => :user, :class_name => "User"
  has_many :down_endorsers, :through => :endorsements, :conditions => "endorsements.status in ('active','inactive') and endorsements.value=-1", :source => :user, :class_name => "User"
    
  has_many :points, :conditions => "points.status in ('published','draft')"
  accepts_nested_attributes_for :points

  has_many :my_points, :conditions => "points.status in ('published','draft')", :class_name => "Point"
  accepts_nested_attributes_for :my_points
  
  has_many :incoming_points, :foreign_key => "other_priority_id", :class_name => "Point"
  has_many :published_points, :conditions => "status = 'published'", :class_name => "Point", :order => "points.helpful_count-points.unhelpful_count desc"
  has_many :points_with_deleted, :class_name => "Point", :dependent => :destroy
  has_many :documents, :dependent => :destroy
  
  has_many :rankings, :dependent => :destroy
  has_many :activities, :dependent => :destroy

  has_many :charts, :class_name => "PriorityChart", :dependent => :destroy
  has_many :ads, :dependent => :destroy
  has_many :notifications, :as => :notifiable, :dependent => :destroy
  
  has_many :changes, :conditions => "status <> 'deleted'", :order => "updated_at desc"
  has_many :approved_changes, :class_name => "Change", :conditions => "status = 'approved'", :order => "updated_at desc"
  has_many :sent_changes, :class_name => "Change", :conditions => "status = 'sent'", :order => "updated_at desc"
  has_many :declined_changes, :class_name => "Change", :conditions => "status = 'declined'", :order => "updated_at desc"
  has_many :changes_with_deleted, :class_name => "Change", :order => "updated_at desc", :dependent => :destroy

  has_many :priority_processes
  
  belongs_to :change # if there is currently a pending change, it will be attached
  
  acts_as_taggable_on :issues
  acts_as_list
  
  define_index do
    indexes name
    indexes category.name, :facet=>true, :as=>"category_name"
    has partner_id, :as=>:partner_id, :type => :integer
    where "priorities.status = 'published'"
  end  

  def category_name
    if category
      category.name
    else
      'No category'
    end
  end
    
  validates_length_of :name, :within => 5..60, :too_long => tr("has a maximum of 60 characters", "model/point"), 
                                               :too_short => tr("please enter more than 5 characters", "model/point")
  validates_uniqueness_of :name, :if => Proc.new { |priority| priority.status == 'published' }
  validates :category_id, :presence => true
  
  # docs: http://www.practicalecommerce.com/blogs/post/122-Rails-Acts-As-State-Machine-Plugin
  acts_as_state_machine :initial => :published, :column => :status
  
  state :passive
  state :draft
  state :published, :enter => :do_publish
  state :deleted, :enter => :do_delete
  state :buried, :enter => :do_bury
  state :inactive
  state :abusive, :enter => :do_abusive
  
  event :publish do
    transitions :from => [:draft, :passive], :to => :published
  end
  
  event :delete do
    transitions :from => [:passive, :draft, :published], :to => :deleted
  end

  event :undelete do
    transitions :from => :deleted, :to => :published, :guard => Proc.new {|p| !p.published_at.blank? }
    transitions :from => :delete, :to => :draft 
  end
  
  event :bury do
    transitions :from => [:draft, :passive, :published, :deleted], :to => :buried
  end
  
  event :deactivate do
    transitions :from => [:draft, :published, :buried], :to => :inactive
  end

  event :abusive do
    transitions :from => :published, :to => :abusive
  end
    
  cattr_reader :per_page
  @@per_page = 25
  
  def to_param
    "#{id}-#{name.parameterize_full}"
  end  
  
  def priority_process_root_node
    PriorityProcess.find :first, :conditions=>"root_node = 1 AND priority_id = #{self.id}"
  end
  
  def content
    self.name
  end
  
  def endorse(user,request=nil,partner=nil,referral=nil)
    return false if not user
    partner = nil if partner and partner.id == 1 # don't log partner if it's the default
    endorsement = self.endorsements.find_by_user_id(user.id)
    if not endorsement
      endorsement = Endorsement.new(:value => 1, :priority => self, :user => user, :partner => partner, :referral => referral)
      endorsement.ip_address = request.remote_ip if request
      endorsement.save
    elsif endorsement.is_down?
      endorsement.flip_up
      endorsement.save
    end
    if endorsement.is_replaced?
      endorsement.activate!
    end
    return endorsement
  end
  
  def oppose(user,request=nil,partner=nil,referral=nil)
    return false if not user
    partner = nil if partner and partner.id == 1 # don't log partner if it's the default
    endorsement = self.endorsements.find_by_user_id(user.id)
    if not endorsement
      endorsement = Endorsement.new(:value => -1, :priority => self, :user => user, :partner => partner, :referral => referral)
      endorsement.ip_address = request.remote_ip if request
      endorsement.save
    elsif endorsement.is_up?
      endorsement.flip_down
      endorsement.save
    end
    if endorsement.is_replaced?
      endorsement.activate!
    end
    return endorsement
  end  
  
  def is_official_endorsed?
    official_value == 1
  end
  
  def is_official_opposed?
    official_value == -1
  end
  
  def is_rising?
    position_7days_change > 0
  end  

  def is_falling?
    position_7days_change < 0
  end
  
  def up_endorsements_count
    Endorsement.where(:priority_id=>self.id, :status=>'active', :value=>1).count
  end
  
  def down_endorsements_count
    Endorsement.where(:priority_id=>self.id, :status=>'active', :value=>-1).count
  end
  
  def is_controversial?
    return false unless down_endorsements_count > 0 and up_endorsements_count > 0
    (up_endorsements_count/down_endorsements_count) > 0.5 and (up_endorsements_count/down_endorsements_count) < 2
  end
  
  def is_buried?
    status == tr("delisted", "model/priority")
  end
  
  def is_top?
    return false if position == 0
    position < Endorsement.max_position
  end
  
  def is_new?
    return true if not self.attribute_present?("created_at")
    created_at > Time.now-(86400*7) or position_7days == 0    
  end

  def is_published?
    ['published','inactive'].include?(status)
  end
  alias :is_published :is_published?
    
  def is_finished?
    official_status > 1 or official_status < 0
  end
  
  def is_failed?
    official_status == -2
  end
  
  def is_successful?
    official_status == 2
  end
  
  def is_compromised?
    official_status == -1
  end
  
  def is_intheworks?
    official_status == 1
  end  
  
  def request=(request)
    if request
      self.ip_address = request.remote_ip
      self.user_agent = request.env['HTTP_USER_AGENT']
    else
      self.ip_address = "127.0.0.1"
      self.user_agent = "Import"
    end
  end
  
  def position_7days_change_percent
    position_7days_change.to_f/(position+position_7days_change).to_f
  end
  
  def position_24hr_change_percent
    position_24hr_change.to_f/(position+position_24hr_change).to_f
  end  
  
  def position_30days_change_percent
    position_30days_change.to_f/(position+position_30days_change).to_f
  end  
  
  def value_name 
    if is_failed?
      tr("Priority failed", "model/priority")
    elsif is_successful?
      tr("Priority succesful", "model/priority")
    elsif is_compromised?
      tr("Priority succesful with compromises", "model/priority")
    elsif is_intheworks?
      tr("Priority in the works", "model/priority")
    else
      tr("Priority has not been processed", "model/priority")
    end
  end
  
  def change_status!(change_status)
    if change_status == 0
      reactivate!
    elsif change_status == 2
      successful!
    elsif change_status == -2
      failed!
    elsif change_status == -1
      in_the_works!
    end
  end

  def reactivate!
    self.status_changed_at = Time.now
    self.official_status = 0
    self.status = 'published'
#    self.change = nil
    self.save(:validate => false)
#    deactivate_endorsements  
  end
  
  def failed!
#    ActivityPriorityOfficialStatusFailed.create(:priority => self, :user => user)
    self.status_changed_at = Time.now
    self.official_status = -2
    self.status = 'inactive'
#    self.change = nil
    self.save(:validate => false)
#    deactivate_endorsements  
  end
  
  def successful!
#    ActivityPriorityOfficialStatusSuccessful.create(:priority => self, :user => user)
    self.status_changed_at = Time.now
    self.official_status = 2
    self.status = 'inactive'
#    self.change = nil    
    self.save(:validate => false)
#    deactivate_endorsements
  end  

  def in_the_works!
#    ActivityPriorityOfficialStatusCompromised.create(:priority => self, :user => user)
    self.status_changed_at = Time.now
    self.official_status = -1
    self.status = 'inactive'
#    self.change = nil    
    self.save(:validate => false)
#    deactivate_endorsements
  end  
  
  def compromised!
    ActivityPriorityOfficialStatusCompromised.create(:priority => self, :user => user)
    self.status_changed_at = Time.now
    self.official_status = -1
    self.status = 'inactive'
 #   self.change = nil    
    self.save(:validate => false)
 #   deactivate_endorsements
  end  

  def deactivate_endorsements
    for e in endorsements.active
      e.finish!
    end    
  end
  
  def reactivate!
    self.status = 'published'
    self.change = nil
    self.status_changed_at = Time.now
    self.official_status = 0
    self.save(:validate => false)
    for e in endorsements.active_and_inactive
      e.update_attribute(:status,'active')
      row = 0
      for ue in e.user.endorsements.active.by_position
        row += 1
        ue.update_attribute(:position,row) unless ue.position == row
        e.user.update_attribute(:top_endorsement_id,ue.id) if e.user.top_endorsement_id != ue.id and row == 1
      end      
    end
  end
  
  def intheworks!
    ActivityPriorityOfficialStatusInTheWorks.create(:priority => self, :user => user)
    self.update_attribute(:status_changed_at, Time.now)
    self.update_attribute(:official_status, 1)
  end  
  
  def official_status_name
    return tr("failed", "model/priority") if official_status == -2
    return tr("compromised", "model/priority") if official_status == -1
    return tr("unknown", "model/priority") if official_status == 0 
    return tr("in the works", "model/priority") if official_status == 1
    return tr("successful", "model/priority") if official_status == 2
  end
  
  def has_change?
    attribute_present?("change_id") and self.status != 'inactive' and change and not change.is_expired?
  end

  def has_tags?
    attribute_present?("cached_issue_list")
  end
  
  def replaced?
    attribute_present?("change_id") and self.status == 'inactive'
  end
  
  def movement_text
    s = ''
    if status == 'buried'
      return tr("delisted", "model/priority").capitalize
    elsif status == 'inactive'
      return tr("inactive", "model/priority").capitalize
    elsif created_at > Time.now-86400
      return tr("new", "model/priority").capitalize
    elsif position_24hr_change == 0 and position_7days_change == 0 and position_30days_change == 0
      return tr("no change", "model/priority").capitalize
    end
    s += '+' if position_24hr_change > 0
    s += '-' if position_24hr_change < 0    
    s += tr("no change", "model/priority") if position_24hr_change == 0
    s += position_24hr_change.abs.to_s unless position_24hr_change == 0
    s += ' today'
    s += ', +' if position_7days_change > 0
    s += ', -' if position_7days_change < 0    
    s += ', ' + tr("no change", "model/priority") if position_7days_change == 0
    s += position_7days_change.abs.to_s unless position_7days_change == 0
    s += ' this week'
    s += ', and +' if position_30days_change > 0
    s += ', and -' if position_30days_change < 0    
    s += ', and ' + tr("no change", "model/priority") if position_30days_change == 0
    s += position_30days_change.abs.to_s unless position_30days_change == 0
    s += ' this month'    
    s
  end
  
  def up_endorser_ids
    endorsements.active_and_inactive.endorsing.collect{|e|e.user_id.to_i}.uniq.compact
  end  
  def down_endorser_ids
    endorsements.active_and_inactive.opposing.collect{|e|e.user_id.to_i}.uniq.compact
  end
  def endorser_ids
    endorsements.active_and_inactive.collect{|e|e.user_id.to_i}.uniq.compact
  end
  def all_priority_ids_in_same_tags
    ts = Tagging.find(:all, :conditions => ["tag_id in (?) and taggable_type = 'Priority'",taggings.collect{|t|t.tag_id}.uniq.compact])
    return ts.collect{|t|t.taggable_id}.uniq.compact
  end
  
  def undecideds
    return [] unless has_tags? and endorsements_count > 2    
    User.find_by_sql("
    select distinct users.* 
    from users, endorsements
    where endorsements.user_id = users.id
    and endorsements.status = 'active'
    and endorsements.priority_id in (#{all_priority_ids_in_same_tags.join(',')})
    and endorsements.user_id not in (#{endorser_ids.join(',')})
    ")
  end
  memoize :up_endorser_ids, :down_endorser_ids, :endorser_ids, :all_priority_ids_in_same_tags, :undecideds
  
  def related(limit=10)
    Priority.find_by_sql(["SELECT priorities.*, count(*) as num_tags
    from taggings t1, taggings t2, priorities
    where 
    t1.taggable_type = 'Priority' and t1.taggable_id = ?
    and t1.tag_id = t2.tag_id
    and t2.taggable_type = 'Priority' and t2.taggable_id = priorities.id
    and t2.taggable_id <> ?
    and priorities.status = 'published'
    group by priorities.id
    order by num_tags desc, priorities.endorsements_count desc
    limit ?",id,id,limit])  
  end  
  
  def merge_into(p2_id,preserve=false,flip=0) #pass in the id of the priority to merge this one into.
    p2 = Priority.find(p2_id) # p2 is the priority that this one will be merged into
    for e in endorsements
      if not exists = p2.endorsements.find_by_user_id(e.user_id)
        e.priority_id = p2.id
        if flip == 1
          if e.value < 0
            e.value = 1 
          else
            e.value = -1
          end
        end   
        e.save(:validate => false)     
      end
    end
    p2.reload
    size = p2.endorsements.active_and_inactive.length
    up_size = p2.endorsements.active_and_inactive.endorsing.length
    down_size = p2.endorsements.active_and_inactive.opposing.length
    Priority.update_all("endorsements_count = #{size}, up_endorsements_count = #{up_size}, down_endorsements_count = #{down_size}", ["id = ?",p2.id]) 

    # look for the activities that should be removed entirely
    for a in Activity.find(:all, :conditions => ["priority_id = ? and type in ('ActivityPriorityDebut','ActivityPriorityNew','ActivityPriorityRenamed','ActivityPriorityFlag','ActivityPriorityFlagInappropriate','ActivityPriorityOfficialStatusCompromised','ActivityPriorityOfficialStatusFailed','ActivityPriorityOfficialStatusIntheworks','ActivityPriorityOfficialStatusSuccessful','ActivityPriorityRising1','ActivityIssuePriority1','ActivityIssuePriorityControversial1','ActivityIssuePriorityOfficial1','ActivityIssuePriorityRising1')",self.id])
      a.destroy
    end    
    #loop through the rest of the activities and move them over
    for a in activities
      if flip == 1
        for c in a.comments
          if c.is_opposer?
            c.is_opposer = false
            c.is_endorser = true
            c.save(:validate => false)
          elsif c.is_endorser?
            c.is_opposer = true
            c.is_endorser = false
            c.save(:validate => false)            
          end
        end
        if a.class == ActivityEndorsementNew
          a.update_attribute(:type,'ActivityOppositionNew')
        elsif a.class == ActivityOppositionNew
          a.update_attribute(:type,'ActivityEndorsementNew')
        elsif a.class == ActivityEndorsementDelete
          a.update_attribute(:type,'ActivityOppositionDelete')
        elsif a.class == ActivityOppositionDelete
          a.update_attribute(:type,'ActivityEndorsementDelete')
        elsif a.class == ActivityEndorsementReplaced
          a.update_attribute(:type,'ActivityOppositionReplaced')
        elsif a.class == ActivityOppositionReplaced 
          a.update_attribute(:type,'ActivityEndorsementReplaced')
        elsif a.class == ActivityEndorsementReplacedImplicit
          a.update_attribute(:type,'ActivityOppositionReplacedImplicit')
        elsif a.class == ActivityOppositionReplacedImplicit
          a.update_attribute(:type,'ActivityEndorsementReplacedImplicit')
        elsif a.class == ActivityEndorsementFlipped
          a.update_attribute(:type,'ActivityOppositionFlipped')
        elsif a.class == ActivityOppositionFlipped
          a.update_attribute(:type,'ActivityEndorsementFlipped')
        elsif a.class == ActivityEndorsementFlippedImplicit
          a.update_attribute(:type,'ActivityOppositionFlippedImplicit')
        elsif a.class == ActivityOppositionFlippedImplicit
          a.update_attribute(:type,'ActivityEndorsementFlippedImplicit')
        end
      end
      if preserve and (a.class.to_s[0..26] == 'ActivityPriorityAcquisition' or a.class.to_s[0..25] == 'ActivityCapitalAcquisition')
      else
        a.update_attribute(:priority_id,p2.id)
      end      
    end
    for a in ads
      a.update_attribute(:priority_id,p2.id)
    end    
    for point in points_with_deleted
      point.priority = p2
      if flip == 1
        if point.value > 0
          point.value = -1
        elsif point.value < 0
          point.value = 1
        end 
        # need to flip the helpful/unhelpful counts
        helpful = point.endorser_helpful_count
        unhelpful = point.endorser_unhelpful_count
        point.endorser_helpful_count = point.opposer_helpful_count
        point.endorser_unhelpful_count = point.opposer_unhelpful_count
        point.opposer_helpful_count = helpful
        point.opposer_unhelpful_count = unhelpful        
      end      
      point.save(:validate => false)      
    end
    for document in documents
      document.priority = p2
      if flip == 1
        if document.value > 0
          document.value = -1
        elsif document.value < 0
          document.value = 1
        end 
        # need to flip the helpful/unhelpful counts
        helpful = document.endorser_helpful_count
        unhelpful = document.endorser_unhelpful_count
        document.endorser_helpful_count = document.opposer_helpful_count
        document.endorser_unhelpful_count = document.opposer_unhelpful_count
        document.opposer_helpful_count = helpful
        document.opposer_unhelpful_count = unhelpful        
      end      
      document.save(:validate => false)      
    end
    for point in incoming_points
      if flip == 1
        point.other_priority = nil
      elsif point.other_priority == p2
        point.other_priority = nil
      else
        point.other_priority = p2
      end
      point.save(:validate => false)
    end
    if not preserve # set preserve to true if you want to leave the Change and the original priority in tact, otherwise they will be deleted
      for c in changes_with_deleted
        c.destroy
      end
    end
    # find any issues they may be the top prioritiy for, and remove
    for tag in Tag.find(:all, :conditions => ["top_priority_id = ?",self.id])
      tag.update_attribute(:top_priority_id,nil)
    end
    # zap all old rankings for this priority
    Ranking.connection.execute("delete from rankings where priority_id = #{self.id.to_s}")
    self.reload
    self.destroy if not preserve
    return p2
  end
  
  def flip_into(p2_id,preserve=false) #pass in the id of the priority to flip this one into.  it'll turn up endorsements into down endorsements and vice versa
    merge_into(p2_id,1)
  end  
  
  def show_url
    if self.partner_id
      Government.current.homepage_url(self.partner) + 'priorities/' + to_param
    else
      Government.current.homepage_url + 'priorities/' + to_param
    end
  end
  
  def show_discussion_url
    show_url + '/discussions'
  end

  def show_top_points_url
    show_url + '/top_points'
  end

  def show_endorsers_url
    show_url + '/endorsers'
  end

  def show_opposers_url
    show_url + '/opposers'
  end
  
  # this uses http://is.gd
  def create_short_url
    self.short_url = open('http://is.gd/create.php?longurl=' + show_url, "UserAgent" => "Ruby-ShortLinkCreator").read[/http:\/\/is\.gd\/\w+(?=" onselect)/]
  end

  def latest_priority_process_at
    latest_priority_process_txt = Rails.cache.read("latest_priority_process_at_#{self.id}")
    unless latest_priority_process_txt      
      priority_process = PriorityProcess.find_by_priority_id(self, :order=>"created_at DESC, stage_sequence_number DESC")
      if priority_process
        time = priority_process.last_changed_at
      else
        time = Time.now-5.years
      end
      if priority_process.stage_sequence_number == 1 and priority_process.process_discussions.count == 0
        stage_txt = "#{t :waits_for_discussion}"
      else
        stage_txt = "#{priority_process.stage_sequence_number}. #{t :parliment_stage_sequence_discussion}"
      end
      latest_priority_process_txt = "#{stage_txt}, #{distance_of_time_in_words_to_now(time)} #{t :since}"
      Rails.cache.write("latest_priority_process_at_#{self.id}", latest_priority_process_txt, :expires_in => 30.minutes)
    end
    latest_priority_process_txt
  end

  def do_abusive
    self.user.do_abusive!(notifications)
    self.update_attribute(:flags_count, 0)
  end

  def flag_by_user(user)
    self.increment!(:flags_count)
    for r in User.active.admins
      notifications << NotificationPriorityFlagged.new(:sender => user, :recipient => r)    
    end
  end  

  private
  def do_publish
    self.published_at = Time.now
    ActivityPriorityNew.create(:user => user, :priority => self)    
  end
  
  def do_delete
    activities.each do |a|
      a.delete!
    end
    endorsements.each do |e|
      e.destroy
    end
    self.deleted_at = Time.now
  end
  
  def do_undelete
    self.deleted_at = nil
  end  
  
  def do_bury
    # should probably send an email notification to the person who submitted it
    # but not doing anything for now.
  end
end
