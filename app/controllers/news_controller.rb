class NewsController < ApplicationController

  before_filter :login_required, :except => [:index, :top, :discussions, :points, :activities, :capitals, :official, :changes, :changes_voting, :changes_activity, :ads, :videos, :comments, :your_discussions, :your_priority_discussions, :your_network_discussions, :your_priorities_created_discussions]
  before_filter :check_for_user, :only => [:your_discussions, :your_priority_discussions, :your_network_discussions, :your_priorities_created_discussions]

  caches_action :top, :discussions, :activities, :points,
                :if => proc {|c| c.do_action_cache? },
                :cache_path => proc {|c| c.action_cache_path},
                :expires_in => 2.minutes

  def index
    redirect_to :action => "discussions"
    return
  end
  
  def videos
    redirect_to :controller => "about"
    return
  end
  
  def discussions
    @page_title = tr("What everyone is discussing at {government_name}", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    @rss_url = url_for(:only_path => false, :action => "comments", :format => "rss")
    if @current_government.users_count > 5000 # only show the last 7 days worth
      @activities = Activity.active.filtered.discussions.for_all_users.last_seven_days.by_recently_updated.paginate :page => params[:page], :per_page => 15
    else
      @activities = Activity.active.filtered.discussions.for_all_users.by_recently_updated.paginate :page => params[:page], :per_page => 15
    end
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.js { render :layout => false, :text => "document.write('" + js_help.escape_javascript(render_to_string(:layout => false, :template => 'activities/discussions_widget_small')) + "');" }
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end 
  
  def comments
    @page_title = tr("Latest comments at {government_name}", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    @comments = Comment.published.last_three_days.by_recently_created.find(:all, :include => :activity).paginate :page => params[:page]
    respond_to do |format|
      format.rss { render :template => "rss/comments" }
      format.xml { render :xml => @comments.to_xml(:include => :user, :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @comments.to_json(:include => :user, :except => NB_CONFIG['api_exclude_fields']) }
    end
  end
  
  def points
    @page_title = tr("Latest activity for points at {government_name}", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    @activities = Activity.active.filtered.points_and_docs.for_all_users.paginate :page => params[:page]
    @rss_url = url_for(:only_path => false, :format => "rss")
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.rss { render :template => "rss/activities" }       
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end  
  
  def activities
    @page_title = tr("Everything happening at {government_name}", "controller/news", :government_name => tr(current_government.name,"Name from database"))
#    if @current_government.users_count > 5000 # only show the last 7 days worth    
#      @activities = Activity.active.filtered.for_all_users.last_seven_days.by_recently_created.paginate :page => params[:page]
#    else
     @activities = Activity.active.filtered.for_all_users.by_recently_created.paginate :page => params[:page]      
#    end
    @rss_url = url_for(:only_path => false, :format => "rss")    
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.rss { render :template => "rss/activities" }
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end 
  end

  def top
    @page_title = tr("Top News at {government_name}", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    @activities = Activity.active.top.filtered.for_all_users.by_recently_created.paginate :page => params[:page]      
    @rss_url = url_for(:only_path => false, :format => "rss")    
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.rss { render :template => "rss/activities" }
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end 
  end
  
  def capital
    @page_title = tr("{currency_name} at {government_name}", "controller/news", :government_name => tr(current_government.name,"Name from database"), :currency_name => current_government.currency_name.titleize)
    @activities = Activity.active.filtered.for_all_users.capital.by_recently_created.paginate :page => params[:page]
    @rss_url = url_for(:only_path => false, :format => "rss")          
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.rss { render :template => "rss/activities" }           
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end  
  
  def changes
    @page_title = tr("Acquisition proposals", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    @changes = Change.suggested.by_recently_created.paginate :page => params[:page]
    respond_to do |format|
      format.html { render :action => "change_list" }
      format.xml { render :xml => @changes.to_xml(:include => [:priority, :new_priority], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @changes.to_json(:include => [:priority, :new_priority], :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end  
  
  def changes_voting
    @page_title = tr("Voting results on acquisition proposals", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    @changes = Change.voting.by_recently_started.paginate :page => params[:page]
    respond_to do |format|
      format.html { render :action => "change_list" }
      format.xml { render :xml => @changes.to_xml(:include => [:priority, :new_priority], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @changes.to_json(:include => [:priority, :new_priority], :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end
  
  def changes_activity
    @page_title = tr("M&A activity at {government_name}", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    @activities = Activity.active.filtered.for_all_users.changes.by_recently_created.paginate :page => params[:page]
    @rss_url = url_for(:only_path => false, :format => "rss")    
    respond_to do |format|
      format.html { render :action => "changes_activity" }
      format.rss { render :template => "rss/activities" }      
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end  
  
  def your_activities
    @page_title = tr("What are you doing at {government_name}?", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    @activities = current_user.activities.active.for_all_users.by_recently_created.paginate :page => params[:page]    
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end
  
  def your_capital
    @page_title = tr("Your {currency_name} at {government_name}", "controller/news", :government_name => tr(current_government.name,"Name from database"), :currency_name => tr(current_government.currency_name.downcase,"Currency name from database"))
    @activities = current_user.activities.active.capital.for_all_users.by_recently_created.paginate :page => params[:page]    
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end
  end  
  
  def your_changes
    @page_title = tr("Your M&A activity at {government_name}", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    @activities = current_user.activities.active.changes.for_all_users.by_recently_created.paginate :page => params[:page]    
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end   
  end  
  
  def your_points
    @page_title = tr("Your points activity at {government_name}", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    # this needs some work
    @activities = current_user.activities.active.points_and_docs.by_recently_created.paginate :page => params[:page]    
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end       
  end  
  
  def your_discussions
    @page_title = tr("Discussions you're following at {government_name}", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    @activities = @user.following_discussion_activities.active.by_recently_updated.paginate :page => params[:page], :per_page => 15
    @rss_url = url_for(:only_path => false, :controller => "rss", :action => "your_comments", :format => "rss", :c => @user.rss_code)
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.js { render :layout => false, :text => "document.write('" + js_help.escape_javascript(render_to_string(:layout => false, :template => 'activities/discussions_widget_small')) + "');" }            
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end
    if logged_in? and request.format == 'html' and current_user.unread_notifications_count > 0
      for n in current_user.received_notifications.comments.unread.all
        n.read!
      end    
    end    
  end    
  
  # doesn't include activities that followers are commenting on
  def your_followers_activities
    @page_title = tr("Your followers' activity at {government_name}", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    @activities = Activity.active.filtered.for_all_users.by_recently_created.paginate :conditions => ["user_id in (?)",current_user.followers.collect{|e|e.user_id}.uniq.compact], :page => params[:page]            
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end       
  end  
  
  # doesn't include activities that followers are commenting on
  def your_followers_discussions
    @page_title = tr("Discussions your followers are participating in", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    @activities = Activity.active.filtered.discussions.by_recently_created.paginate :conditions => ["user_id in (?)",current_user.followers.collect{|e|e.user_id}.uniq.compact], :page => params[:page], :per_page => 15
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end     
  end  
  
  def your_followers_points
    @page_title = tr("Points and documents from your followers", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    @activities = Activity.active.filtered.points_and_docs.paginate :conditions => ["user_id in (?)",current_user.followers.collect{|e|e.user_id}.uniq.compact], :page => params[:page]      
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end      
  end  
  
  def your_followers_capital
    @page_title = tr("Your followers' {currency_name}", "controller/news", :government_name => tr(current_government.name,"Name from database"), :currency_name => tr(current_government.currency_name.downcase,"Currency name from database"))
    @activities = Activity.active.filtered.capital.by_recently_created.paginate :conditions => ["user_id in (?)",current_user.followers.collect{|e|e.user_id}.uniq.compact], :page => params[:page]
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end     
  end  
  
  def your_followers_changes
    @page_title = tr("M&A activity from your followers", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    @activities = Activity.active.filtered.changes.by_recently_created.paginate :conditions => ["user_id in (?)",current_user.followers.collect{|e|e.user_id}.uniq.compact], :page => params[:page]
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end 
  end  
  
  # doesn't include activities that followers are commenting on
  def your_network_activities
    @page_title = tr("What's happening in your {government_name}?", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    if current_following_ids.empty?
      @activities = Activity.active.filtered.for_all_users.by_recently_created.paginate :conditions => "user_id = #{current_user.id.to_s}", :page => params[:page]      
    else
      @activities = Activity.active.filtered.for_all_users.by_recently_created.paginate :conditions => "user_id in (#{current_user.id.to_s},#{current_following_ids.join(',')})", :page => params[:page]
    end
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end      
  end  

  # doesn't include activities that followers are commenting on
  def your_network_discussions
    @page_title = tr("Discussions in your network", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    if @user.followings_count == 0
      @activities = Activity.active.filtered.discussions.by_recently_created.paginate :conditions => "user_id = #{@user.id.to_s}", :page => params[:page], :per_page => 15
    else
      @activities = Activity.active.filtered.discussions.by_recently_created.paginate :conditions => "user_id in (#{@user.id.to_s},#{@user.followings.up.collect{|f|f.other_user_id}.join(',')})", :page => params[:page], :per_page => 15
    end    
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.js { render :layout => false, :text => "document.write('" + js_help.escape_javascript(render_to_string(:layout => false, :template => 'activities/discussions_widget_small')) + "');" }            
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end     
  end  
  
  def your_network_points
    @page_title = tr("Points and documents in your network", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    if current_following_ids.empty?
      @activities = Activity.active.filtered.points_and_docs.paginate :conditions => "user_id = #{current_user.id.to_s}", :page => params[:page]      
    else
      @activities = Activity.active.filtered.points_and_docs.paginate :conditions => "user_id in (#{current_user.id.to_s},#{current_following_ids.join(',')})", :page => params[:page]
    end    
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end
  end  
  
  def your_network_capital
    @page_title = tr("{currency_name} in your network", "controller/news", :government_name => tr(current_government.name,"Name from database"), :currency_name => current_government.currency_name.titleize)
    if current_following_ids.empty?
      @activities = Activity.active.filtered.capital.by_recently_created.paginate :conditions => "user_id = #{current_user.id.to_s}", :page => params[:page]      
    else
      @activities = Activity.active.filtered.capital.by_recently_created.paginate :conditions => "user_id in (#{current_user.id.to_s},#{current_following_ids.join(',')})", :page => params[:page]
    end    
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end       
  end  
  
  def your_network_changes
    @page_title = tr("M&A activity in your network", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    if current_following_ids.empty?
      @activities = Activity.active.filtered.changes.by_recently_created.paginate :conditions => "user_id = #{current_user.id.to_s}", :page => params[:page]      
    else
      @activities = Activity.active.filtered.changes.by_recently_created.paginate :conditions => "user_id in (#{current_user.id.to_s},#{current_following_ids.join(',')})", :page => params[:page]
    end    
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end  
  
  def your_priority_activities
    @page_title = tr("What's happening on {government_name}?", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    @activities = nil
    if current_priority_ids.any?
      @activities = Activity.active.filtered.last_seven_days.by_recently_created.paginate :conditions => ["priority_id in (?)",current_priority_ids], :page => params[:page]
    end
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end
  end
  
  def your_priority_official
    @page_title = tr("What {official_user_name} is doing on {government_name}", "controller/news", :government_name => tr(current_government.name,"Name from database"), :official_user_name => current_government.official_user.name)
    @activities = nil
    if current_priority_ids.any?
      @activities = Activity.active.filtered.by_recently_created.paginate :conditions => ["(type like 'ActivityPriorityOfficialStatus%' or user_id = #{current_government.official_user_id}) and priority_id in (?)",current_priority_ids], :page => params[:page]
    end
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end  
  
  def your_priority_changes
    @page_title = tr("Acquisitions proposed on {government_name}", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    @changes = nil
    if current_priority_ids.any?
      @changes = Change.suggested.by_recently_created.paginate :conditions => ["priority_id in (?)",current_priority_ids], :page => params[:page]
    end
    respond_to do |format|
      format.html { render :action => "change_list" }
      format.xml { render :xml => @changes.to_xml(:include => [:priority, :new_priority], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @changes.to_json(:include => [:priority, :new_priority], :except => NB_CONFIG['api_exclude_fields']) }
    end          
  end  
  
  def your_priority_changes_voting
    @page_title = tr("Acquisitions to vote on", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    @changes = nil
    if current_priority_ids.any?
      @changes = Change.voting.by_recently_started.paginate :conditions => ["priority_id in (?)",current_priority_ids], :page => params[:page]
    end
    respond_to do |format|
      format.html { render :action => "change_list" }
      format.xml { render :xml => @changes.to_xml(:include => [:priority, :new_priority], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @changes.to_json(:include => [:priority, :new_priority], :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end  
  
  def your_priority_changes_activity
    @page_title = tr("M&A activity on {government_name}", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    @activities = nil
    if current_priority_ids.any?
      @activities = Activity.active.filtered.changes.for_all_users.by_recently_created.paginate :conditions => ["priority_id in (?)",current_priority_ids], :page => params[:page]
    end
    respond_to do |format|
      format.html { render :action => "changes_activity" }
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end
  end  
  
  def your_priority_discussions
    @page_title = tr("Discussions on {government_name}", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    @activities = nil
    if @user.endorsements_count > 0
      @activities = Activity.active.filtered.last_seven_days.discussions.for_all_users.by_recently_updated.paginate :conditions => ["priority_id in (?)",@user.endorsements.active_and_inactive.collect{|e|e.priority_id}], :page => params[:page], :per_page => 15
    end
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.js { render :layout => false, :text => "document.write('" + js_help.escape_javascript(render_to_string(:layout => false, :template => 'activities/discussions_widget_small')) + "');" }            
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end       
  end
  
  def your_priority_points
    @page_title = tr("Points and documents on {government_name}", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    @activities = nil
    if current_priority_ids.any?  
      @activities = Activity.active.filtered.last_seven_days.points_and_docs.paginate :conditions => ["priority_id in (?)",current_priority_ids], :page => params[:page]
    end
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end
  
  def your_priorities_created_activities
    @page_title = tr("Everything happening on priorities you created", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    @activities = nil
    created_priority_ids = current_user.created_priorities.collect{|p|p.id}
    if created_priority_ids.any?
      @activities = Activity.active.filtered.by_recently_created.paginate :conditions => ["priority_id in (?)",created_priority_ids], :page => params[:page]
    end
    @rss_url = url_for(:only_path => false, :controller => "rss", :action => "your_priorities_created_activities", :format => "rss", :c => current_user.rss_code)
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end
  end
  
  def your_priorities_created_official
    @page_title = tr("What {official_user_name} is doing on priorities you created", "controller/news", :government_name => tr(current_government.name,"Name from database"), :official_user_name => current_government.official_user.name)
    @activities = nil
    created_priority_ids = current_user.created_priorities.collect{|p|p.id}
    if created_priority_ids.any?
      @activities = Activity.active.filtered.by_recently_created.paginate :conditions => ["(type like 'ActivityPriorityOfficialStatus%' or user_id = #{current_government.official_user_id}) and priority_id in (?)",created_priority_ids], :page => params[:page]
    end
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end  
  
  def your_priorities_created_changes
    @page_title = tr("M&A activity on priorities you created", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    @activities = nil
    created_priority_ids = current_user.created_priorities.collect{|p|p.id}
    if created_priority_ids.any?
      @activities = Activity.active.filtered.changes.for_all_users.by_recently_created.paginate :conditions => ["priority_id in (?)",created_priority_ids], :page => params[:page]
    end
    respond_to do |format|
      format.html { render :action => "changes_activity" }
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end
  end  
  
  def your_priorities_created_discussions
    @page_title = tr("Discussions on priorities you created", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    @activities = nil
    created_priority_ids = @user.created_priorities.collect{|p|p.id}
    if created_priority_ids.any?   
      @activities = Activity.active.filtered.discussions.for_all_users.by_recently_updated.paginate :conditions => ["priority_id in (?)",created_priority_ids], :page => params[:page], :per_page => 15
    end
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.js { render :layout => false, :text => "document.write('" + js_help.escape_javascript(render_to_string(:layout => false, :template => 'activities/discussions_widget_small')) + "');" }            
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end       
  end
  
  def your_priorities_created_points
    @page_title = tr("Points activity on priorities you created", "controller/news", :government_name => tr(current_government.name,"Name from database"))
    @activities = nil
    created_priority_ids = current_user.created_priorities.collect{|p|p.id}
    if created_priority_ids.any?
      @activities = Activity.active.filtered.points_and_docs.paginate :conditions => ["priority_id in (?)",created_priority_ids], :page => params[:page]
    end
    respond_to do |format|
      format.html { render :action => "activity_list" }
      format.xml { render :xml => @activities.to_xml(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => [:user, :comments], :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end
  
  private
  def check_for_user
    if params[:user_id]
      @user = User.find(params[:user_id])
    elsif logged_in?
      @user = current_user
    else
      access_denied and return
    end
  end
  
end
