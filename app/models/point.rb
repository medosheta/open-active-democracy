class Point < ActiveRecord::Base

  acts_as_set_partner :table_name=>"points"

  scope :published, :conditions => "points.status = 'published'"
  scope :by_helpfulness, :order => "points.score desc"
  scope :by_endorser_helpfulness, :conditions => "points.endorser_score > 0", :order => "points.endorser_score desc"
  scope :by_neutral_helpfulness, :conditions => "points.neutral_score > 0", :order => "points.neutral_score desc"    
  scope :by_opposer_helpfulness, :conditions => "points.opposer_score > 0", :order => "points.opposer_score desc"
  scope :up, :conditions => "points.endorser_score > 0"
  scope :neutral, :conditions => "points.neutral_score > 0"
  scope :down, :conditions => "points.opposer_score > 0"    
  scope :up_value, :conditions => "points.value > 0"
  scope :neutral_value, :conditions => "points.value = 0"
  scope :down_value, :conditions => "points.value < 0"    
  scope :by_recently_created, :order => "points.created_at desc"
  scope :by_recently_updated, :order => "points.updated_at desc"  
  scope :flagged, :conditions => "flags_count > 0" 
  scope :published, :conditions => "questions.status = 'published'"
  scope :unpublished, :conditions => "questions.status not in ('published','abusive')"

  scope :revised, :conditions => "revisions_count > 1"
  scope :top, :order => "points.score desc"
  scope :one, :limit => 1
  scope :five, :limit => 5
  scope :since, lambda{|time| {:conditions=>["questions.created_at>?",time]}}

  belongs_to :user
  belongs_to :priority
  belongs_to :other_priority, :class_name => "Priority"
  belongs_to :revision # the current revision
  
  has_many :revisions, :dependent => :destroy
  has_many :activities, :dependent => :destroy, :order => "activities.created_at desc"
  
  has_many :author_users, :through => :revisions, :select => "distinct users.*", :source => :user, :class_name => "User"
  
  has_many :point_qualities, :order => "created_at desc", :dependent => :destroy
  has_many :helpfuls, :class_name => "PointQuality", :conditions => "value = true", :order => "created_at desc"
  has_many :unhelpfuls, :class_name => "PointQuality", :conditions => "value = false", :order => "created_at desc"
  
  has_many :capitals, :as => :capitalizable, :dependent => :nullify

  has_many :notifications, :as => :notifiable, :dependent => :destroy
  
  define_index do
    indexes name
    indexes content
    indexes priority.category.name, :facet=>true, :as=>"category_name"
    has partner_id, :as=>:partner_id, :type => :integer
    where "points.status = 'published'"    
  end
  
  def category_name
    if priority.category
      priority.category.name
    else
      'No category'
    end
  end
  
  cattr_reader :per_page
  @@per_page = 15  
  
  def to_param
    "#{id}-#{name.parameterize_full}"
  end  
  
  after_destroy :delete_point_quality_activities
  before_destroy :remove_counts
#  after_commit :setup_revision
  before_save :ensure_request_and_user_are_set
  
  validates_length_of :name, :within => 5..60, :too_long => tr("has a maximum of 60 characters", "model/point"), 
                                               :too_short => tr("please enter more than 5 characters", "model/point")
    #validates_uniqueness_of :name
  # this is actually just supposed to be 500, but bumping it to 520 because the javascript counter doesn't include carriage returns in the count, whereas this does.
  validates_length_of :content, :within => 5..520, :too_long => tr("has a maximum of 500 characters", "model/point"), 
                                                   :too_short => tr("please enter more than 5 characters", "model/point")
  
  # docs: http://www.practicalecommerce.com/blogs/post/122-Rails-Acts-As-State-Machine-Plugin
  acts_as_state_machine :initial => :published, :column => :status
  
  state :draft
  state :published, :enter => :do_publish
  state :deleted, :enter => :do_delete
  state :buried, :enter => :do_bury
  state :abusive, :enter => :do_abusive
  
  event :publish do
    transitions :from => [:draft], :to => :published
  end
  
  event :delete do
    transitions :from => [:draft, :published,:buried], :to => :deleted
  end

  event :undelete do
    transitions :from => :deleted, :to => :published, :guard => Proc.new {|p| !p.published_at.blank? }
    transitions :from => :deleted, :to => :draft 
  end
  
  event :bury do
    transitions :from => [:draft, :published, :deleted], :to => :buried
  end
  
  event :unbury do
    transitions :from => :buried, :to => :published, :guard => Proc.new {|p| !p.published_at.blank? }
    transitions :from => :buried, :to => :draft     
  end

  event :abusive do
    transitions :from => :published, :to => :abusive
  end

  def do_abusive
    self.user.do_abusive!(notifications)
    self.update_attribute(:flags_count, 0)
  end

  def flag_by_user(user)
    self.increment!(:flags_count)
    for r in User.active.admins
      notifications << NotificationPointFlagged.new(:sender => user, :recipient => r)    
    end
  end

  def do_publish
    self.published_at = Time.now
    add_counts
    priority.save(:validate => false)    
  end
  
  def do_delete
    remove_counts
    activities.each do |a|
      a.delete!
    end
    capital_earned = capitals.sum(:amount)
    if capital_earned != 0
      self.capitals << CapitalPointHelpfulDeleted.new(:recipient => user, :amount => (capital_earned*-1)) 
    end    
    priority.save(:validate => false)
    for r in revisions
      r.delete!
    end
  end

  def setup_revision
    Revision.create_from_point(self)
  end
 
  def ensure_request_and_user_are_set
    if self.priority
      self.ip_address = self.priority.ip_address
      self.user_agent = self.priority.user_agent
      self.user_id = self.priority.user_id
      Rails.logger.debug("SELF PRIORITY: #{pp self.priority.inspect}")
    else
      Rails.logger.error("No Priority for point id: #{self.id}")
      puts "No Priority for point id: #{self.id}"
    end
  end
  
  def do_bury
    remove_counts
    priority.save(:validate => false)    
  end
  
  def add_counts
    priority.up_points_count += 1 if is_up?
    priority.down_points_count += 1 if is_down?
    priority.neutral_points_count += 1 if is_neutral?        
    priority.points_count += 1
    user.increment!(:points_count)    
  end
  
  def remove_counts
    priority.up_points_count -= 1 if is_up?
    priority.down_points_count -= 1 if is_down?
    priority.neutral_points_count -= 1 if is_neutral?        
    priority.points_count -= 1
    user.decrement!(:points_count)        
  end
  
  def delete_point_quality_activities
    qs = Activity.find(:all, :conditions => ["point_id = ? and type in ('ActivityPointHelpfulDelete','ActivityPointUnhelpfulDelete')",self.id])
    for q in qs
      q.destroy
    end
  end

  def name_with_type
    return name unless is_down?
    "[#{tr("Against", "model/point")}] " + name
  end

  def text
    s = name_with_type
    s += "\r\nIn support of " + other_priority.name if has_other_priority?
    s += "\r\n" + content
    s += "\r\nSource: " + website_link if has_website?
    return s
  end

  def authors
    revisions.count(:group => :user, :order => "count_all desc")
  end
  
  def editors
    revisions.count(:group => :user, :conditions => ["revisions.user_id <> ?", user_id], :order => "count_all desc")
  end  
  
  def is_up?
    value > 0
  end
  
  def is_down?
    value < 0
  end
  
  def is_neutral?
    value == 0
  end
  
  def is_deleted?
    status == 'deleted'
  end

  def is_published?
    ['published'].include?(status)
  end
  alias :is_published :is_published?
  
  auto_html_for(:content) do
    html_escape
    youtube :width => 330, :height => 210
    vimeo :width => 330, :height => 180
    link :target => "_blank", :rel => "nofollow"
  end  

  def calculate_score(tosave=false,current_endorsement=nil)
    old_score = self.score
    old_endorser_score = self.endorser_score
    old_opposer_score = self.opposer_score
    old_neutral_score = self.neutral_score
    self.score = 0
    self.endorser_score = 0
    self.opposer_score = 0
    self.neutral_score = 0
    for q in point_qualities.find(:all, :include => :user)
      if q.is_helpful?
        vote = q.user.quality_factor
      else
        vote = -q.user.quality_factor
      end
      self.score += vote
      if q.is_endorser?
        self.endorser_score += vote
      elsif q.is_opposer?
        self.opposer_score += vote        
      else
        self.neutral_score += vote
      end
    end
    
    # did any particular group find this helpful?
    if self.opposer_score > 1 and old_opposer_score <= 1
      capitals << CapitalPointHelpfulOpposers.new(:recipient => user, :amount => 1)  
    end    
    if self.endorser_score > 1 and old_endorser_score <= 1
      capitals << CapitalPointHelpfulEndorsers.new(:recipient => user, :amount => 1)
    end    
    if self.neutral_score > 1 and old_neutral_score <= 1
      capitals << CapitalPointHelpfulUndeclareds.new(:recipient => user, :amount => 1)
    end        
    
    # did people find this actually unhelpful?
    if self.endorser_score < -0.5 and old_endorser_score >= -0.5
      endorsement = current_endorsement || Endorsement.find_by_user_id_and_priority_id(self.user_id, self.priority_id)
      if endorsement and endorsement.is_up?
        capitals << CapitalPointHelpfulEndorsers.new(:recipient => user, :amount => -1)
      end
    end
    if self.opposer_score < -0.5 and old_opposer_score >= -0.5
      endorsement = current_endorsement || Endorsement.find_by_user_id_and_priority_id(self.user_id, self.priority_id)
      if endorsement and endorsement.is_down?
        capitals << CapitalPointHelpfulOpposers.new(:recipient => user, :amount => -1)
      end
    end
    if self.neutral_score < -0.5 and old_neutral_score >= -0.5
      endorsement = current_endorsement || Endorsement.find_by_user_id_and_priority_id(self.user_id, self.priority_id)
      if not endorsement
        capitals << CapitalPointHelpfulUndeclareds.new(:recipient => user, :amount => -1)
      end
    end
    
    # did both endorsers & opposers find this helpful or unhelpful?
    if self.opposer_score > 1 and self.endorser_score > 1 and (old_opposer_score <= 1 or old_endorser_score <= 1)
      capitals << CapitalPointHelpfulEveryone.new(:recipient => user, :amount => 1)
    end      
    if self.opposer_score < -0.5 and self.endorser_score < -0.5 and (old_opposer_score >= -0.5 or old_endorser_score >= -0.5)
      # charge for a point that both opposers and endorsers found unhelpful
      capitals << CapitalPointHelpfulEveryone.new(:recipient => user, :amount => -1)        
    end    

    if old_score != self.score and tosave
      self.save(:validate => false)
    end    
  end
  
  def opposers_helpful?
    opposer_score > 0
  end
  
  def endorsers_helpful?
    endorser_score > 0    
  end
  
  def neutrals_helpful?
    neutral_score > 0    
  end  

  def everyone_helpful?
    score > 0    
  end
  
  def helpful_endorsers_capital_spent
    capitals.sum(:amount, :conditions => "type = 'CapitalPointHelpfulEndorsers'")
  end

  def helpful_opposers_capital_spent
    capitals.sum(:amount, :conditions => "type = 'CapitalPointHelpfulOpposers'")
  end
  
  def helpful_undeclareds_capital_spent
    capitals.sum(:amount, :conditions => "type = 'CapitalPointHelpfulUndeclareds'")
  end  
  
  def helpful_everyone_capital_spent
    capitals.sum(:amount, :conditions => "type = 'CapitalPointHelpfulEveryone'")
  end  

  def priority_name
    priority.name if priority
  end
  
  def priority_name=(n)
    self.priority = Priority.find_by_name(n) unless n.blank?
  end
  
  def other_priority_name
    other_priority.name if other_priority
  end
  
  def other_priority_name=(n)
    self.other_priority = Priority.find_by_name(n) unless n.blank?
  end

  def has_other_priority?
    attribute_present?("other_priority_id")
  end
  
  def website_link
    return nil if self.website.nil?
    wu = website
    wu = 'http://' + wu if wu[0..3] != 'http'
    return wu    
  end  
  
  def has_website?
    attribute_present?("website")
  end
  
  def show_url
    if self.partner_id
      Government.current.homepage_url(self.partner) + 'points/' + to_param
    else
      Government.current.homepage_url + 'points/' + to_param
    end
  end
  
  def calculate_importance
  	PointImportanceScore.calculate_score(self.id)
  end

  def set_importance(user_id, score)
  	PointImportanceScore.update_or_create(self.id, user_id, score)
  end
end
