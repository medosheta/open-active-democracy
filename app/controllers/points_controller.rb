class PointsController < ApplicationController
 
  before_filter :login_required, :only => [:new, :create, :quality, :unquality, :your_priorities, :your_index, :destroy, :update_importance]
  before_filter :admin_required, :only => [:edit, :update]

  caches_action :newest, :revised,
                :if => proc {|c| c.do_action_cache?},
                :cache_path => proc {|c| c.action_cache_path},
                :expires_in => 5.minutes

  def index
    redirect_to :action=>:newest
  end
 
  def your_index
    @page_title = tr("Your points", "controller/points", :government_name => tr(current_government.name,"Name from database"))
    @points = Point.filtered.published.by_recently_created.paginate :conditions => ["user_id = ?", current_user.id], :include => :priority, :page => params[:page], :per_page => params[:per_page]
    get_qualities
    respond_to do |format|
      format.html { render :action => "index" }
      format.xml { render :xml => @points.to_xml(:include => [:priority, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @points.to_json(:include => [:priority, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
    end
  end
  
  def newest
    @page_title = tr("Newest points", "controller/points", :government_name => tr(current_government.name,"Name from database"))
    @points = Point.filtered.published.by_recently_created.paginate :include => :priority, :page => params[:page], :per_page => params[:per_page]
    @rss_url = url_for :only_path => false, :format => "rss"
    get_qualities
    respond_to do |format|
      format.html { render :action => "index" }
      format.rss { render :template => "rss/points" }
      format.xml { render :xml => @points.to_xml(:include => [:priority, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @points.to_json(:include => [:priority, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
    end
  end  
  
  def for_and_against
  	@page_title = tr("Points for and against", "controller/points", :government_name => tr(current_government.name,"Name from database"))
    @priority=Priority.find(params[:id])
  	@points_new_up = @priority.points.published.by_recently_created.up_value.five
  	@points_new_down = @priority.points.published.by_recently_created.down_value.five
  	@points_top_up = @priority.points.published.by_helpfulness.up_value.five
  	@points_top_down = @priority.points.published.by_helpfulness.down_value.five
  	# @rss_url = url_for :only_path => false, :format => "rss"
  	respond_to do |format|
  		format.html { render :action => "for_and_against" }
  		#format.rss { render :template => "rss/points" }
  		#format.xml { render :xml => @points.to_xml(:include => [:priority, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
  		#format.json { render :json => @points.to_json(:include => [:priority, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
  		format.js do
  			render :update do |page|
  				page.replace_html 'pro_top', :partial => "brbox", :locals => {:id => "pro_top", :points => @points_top_up}
  				page.replace_html 'con_top', :partial => "brbox", :locals => {:id => "con_top", :points => @points_top_down}
  				page.replace_html 'pro_new', :partial => "brbox", :locals => {:id => "pro_new", :points => @points_new_up}
  				page.replace_html 'con_new', :partial => "brbox", :locals => {:id => "con_new", :points => @points_new_down}
  			end
  		end
  	end
  end  	

  def all_points
  	if params[:foragainst] == "yes"
  		@points_new = Point.published.up.by_recently_created :include => :priority
  		@points_top = Point.published.up.top :include => :priority
  		@yesno = "J&aacute;"
  	elsif params[:foragainst] == "no"
  		@points_new = Point.published.down.by_recently_created :include => :priority
  		@points_top = Point.published.down.top :include => :priority	
  		@yesno = "Nei"
  	end
  	
  	@page_title = tr("Points for and against", "controller/points", :government_name => tr(current_government.name,"Name from database"))
  	respond_to do |format|
  		format.html { render :action => "all_points" }
  	end
  end
  
  def your_priorities
    @page_title = tr("Points on {government_name}", "controller/points", :government_name => tr(current_government.name,"Name from database"))
    if current_user.endorsements_count > 0    
      if current_user.up_endorsements_count > 0 and current_user.down_endorsements_count > 0
        @points = Point.published.by_recently_created.paginate :conditions => ["(points.priority_id in (?) and points.endorser_helpful_count > 0) or (points.priority_id in (?) and points.opposer_helpful_count > 0)",current_user.endorsements.active_and_inactive.endorsing.collect{|e|e.priority_id}.uniq.compact,current_user.endorsements.active_and_inactive.opposing.collect{|e|e.priority_id}.uniq.compact], :include => :priority, :page => params[:page], :per_page => params[:per_page]
      elsif current_user.up_endorsements_count > 0
        @points = Point.published.by_recently_created.paginate :conditions => ["points.priority_id in (?) and points.endorser_helpful_count > 0",current_user.endorsements.active_and_inactive.endorsing.collect{|e|e.priority_id}.uniq.compact], :include => :priority, :page => params[:page], :per_page => params[:per_page]
      elsif current_user.down_endorsements_count > 0
        @points = Point.published.by_recently_created.paginate :conditions => ["points.priority_id in (?) and points.opposer_helpful_count > 0",current_user.endorsements.active_and_inactive.opposing.collect{|e|e.priority_id}.uniq.compact], :include => :priority, :page => params[:page], :per_page => params[:per_page]
      end
      get_qualities      
    else
      @points = nil
    end
    respond_to do |format|
      format.html { render :action => "index" }
      format.xml { render :xml => @points.to_xml(:include => [:priority, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @points.to_json(:include => [:priority, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end 
 
  def revised
    @page_title = tr("Recently revised points", "controller/points", :government_name => tr(current_government.name,"Name from database"))
    @revisions = Revision.published.by_recently_created.find(:all, :include => :point, :conditions => "points.revisions_count > 1").paginate :page => params[:page], :per_page => params[:per_page]
    @qualities = nil
    if logged_in? and @revisions.any? # pull all their qualities on the points shown
      @qualities = PointQuality.find(:all, :conditions => ["point_id in (?) and user_id = ? ", @revisions.collect {|c| c.point_id},current_user.id])
    end    
    respond_to do |format|
      format.html
      format.xml { render :xml => @revisions.to_xml(:include => [:point, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @revisions.to_json(:include => [:point, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
    end    
  end 
 
  # GET /points/1
  def show
    @point = Point.find(params[:id])
    if @point.is_deleted?
      flash[:error] = tr("That point was deleted", "controller/points")
      redirect_to @point.priority
      return
    end    
    @page_title = @point.name
    @priority = @point.priority
    if logged_in? 
      @quality = @point.point_qualities.find_by_user_id(current_user.id) 
    else
      @quality = nil
    end
    @points = nil
    if @priority.down_points_count > 1 and @point.is_down?
      @points = @priority.points.published.down.by_recently_created.find(:all, :conditions => "id <> #{@point.id}", :include => :priority, :limit => 3)
    elsif @priority.up_points_count > 1 and @point.is_up?
      @points = @priority.points.published.up.by_recently_created.find(:all, :conditions => "id <> #{@point.id}", :include => :priority, :limit => 3)
    elsif @priority.neutral_points_count > 1 and @point.is_neutral?
      @points = @priority.points.published.neutral.by_recently_created.find(:all, :conditions => "id <> #{@point.id}", :include => :priority, :limit => 3)        
    end
    get_qualities if @points and @points.any?
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @point.to_xml(:include => [:priority, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @point.to_json(:include => [:priority, :other_priority], :except => NB_CONFIG['api_exclude_fields']) }
    end
  end

  # GET /priorities/1/points/new
  def new
    load_endorsement
    @point = @priority.points.new
    @page_title = tr("Add a point to {priority_name}", "controller/points", :priority_name => @priority.name)
    @point.value = @endorsement.value if @endorsement
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    @point = Point.find(params[:id])
    @priority = @point.priority
  end

  # POST /priorities/1/points
  def create
    load_endorsement
    @priority = Priority.find(params[:priority_id])    
    @point = @priority.points.new(params[:point])
    @point.user = current_user
    @saved = @point.save
    respond_to do |format|
      if @saved
        Revision.create_from_point(@point,request.remote_ip,request.env['HTTP_USER_AGENT'])
        session[:goal] = 'point'
        flash[:notice] = tr("Thanks for contributing your point", "controller/points")
        if current_facebook_user
          #flash[:user_action_to_publish] = UserPublisher.create_point(current_facebook_user, @point, @priority)
        end          
        @quality = @point.point_qualities.find_or_create_by_user_id_and_value(current_user.id,true)
        format.html { redirect_to(top_points_priority_url(@priority)) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /points/1
  def update
    @point = Point.find(params[:id])
    @priority = @point.priority
    respond_to do |format|
      if @point.update_attributes(params[:point])
        flash[:notice] = tr("Saved {point_name}", "controller/points", :point_name => @point.name)
        format.html { redirect_to(@point) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  # GET /points/1/activity
  def activity
    @point = Point.find(params[:id])
    @page_title = tr("Activity regarding {point_name}", "controller/points", :point_name => @point.name)
    @priority = @point.priority
    if logged_in? 
      @quality = @point.point_qualities.find_by_user_id(current_user.id) 
    else
      @quality = nil
    end
    @activities = @point.activities.active.paginate :page => params[:page], :per_page => params[:per_page]
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @activities.to_xml(:include => :comments, :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => :comments, :except => NB_CONFIG['api_exclude_fields']) }
    end
  end  

  # GET /points/1/discussions
  def discussions
    @point = Point.find(params[:id])
    @page_title = tr("Discussions on {point_name}", "controller/points", :point_name => @point.name)
    @priority = @point.priority
    if logged_in? 
      @quality = @point.point_qualities.find_by_user_id(current_user.id) 
    else
      @quality = nil
    end
    @activities = @point.activities.active.discussions.paginate :page => params[:page], :per_page => params[:per_page]
    respond_to do |format|
      format.html { render :action => "activity" }
      format.xml { render :xml => @activities.to_xml(:include => :comments, :except => NB_CONFIG['api_exclude_fields']) }
      format.json { render :json => @activities.to_json(:include => :comments, :except => NB_CONFIG['api_exclude_fields']) }
    end
  end  
  
  # POST /points/1/quality
  def quality
    @point = Point.find(params[:id])
    @quality = @point.point_qualities.find_or_create_by_user_id_and_value(current_user.id,params[:value])
    @point.reload    
    respond_to do |format|
      format.js {
        render :update do |page|
          if params[:region] == "point_detail"
            page.replace_html 'point_' + @point.id.to_s + '_helpful_button', render(:partial => "points/button", :locals => {:point => @point, :quality => @quality })
            page.replace_html 'point_' + @point.id.to_s + '_helpful_chart', render(:partial => "documents/helpful_chart", :locals => {:document => @point })            
          elsif params[:region] = "point_inline"
#            page.select("point_" + @point.id.to_s + "_quality").each { |item| item.replace_html(render(:partial => "points/button_small", :locals => {:point => @point, :quality => @quality, :priority => @point.priority}) ) }                       
            page.replace_html 'point_' + @point.id.to_s + '_quality', render(:partial => "points/button_small", :locals => {:point => @point, :quality => @quality, :priority => @point.priority}) 
            page.replace_html 'point_' + @point.id.to_s + '_quality_newest', render(:partial => "points/button_small", :locals => {:point => @point, :quality => @quality, :priority => @point.priority}) 
          end
        end        
      }
    end
  end  

  # POST /points/1/unquality
  def unquality
    @point = Point.find(params[:id])
    @qualities = @point.point_qualities.find(:all, :conditions => ["user_id = ?",current_user.id])
    for quality in @qualities
      quality.destroy
    end
    @point.reload
    respond_to do |format|
      format.js {
        render :update do |page|
          if params[:region] == "point_detail"
            page.replace_html 'point_' + @point.id.to_s + '_helpful_button', render(:partial => "points/button", :locals => {:point => @point, :quality => @quality })
            page.replace_html 'point_' + @point.id.to_s + '_helpful_chart', render(:partial => "documents/helpful_chart", :locals => {:document => @point })            
          elsif params[:region] = "point_inline"
#            page.select("point_" + @point.id.to_s + "_quality").each { |item| item.replace_html(render(:partial => "points/button_small", :locals => {:point => @point, :quality => @quality, :priority => @point.priority}) ) }
            page.replace_html 'point_' + @point.id.to_s + '_quality', render(:partial => "points/button_small", :locals => {:point => @point, :quality => @quality, :priority => @point.priority}) 
            page.replace_html 'point_' + @point.id.to_s + '_quality_newest', render(:partial => "points/button_small", :locals => {:point => @point, :quality => @quality, :priority => @point.priority}) 
          end          
        end       
      }
    end
  end  
  
  # GET /points/1/unhide
  def unhide
    @point = Point.find(params[:id])
    @priority = @point.priority
    @quality = nil
    if logged_in?
      @quality = @point.point_qualities.find_by_user_id(current_user.id)
    end
    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace 'point_' + @point.id.to_s, render(:partial => "points/show", :locals => {:point => @point, :quality => @quality})
        end
      }
    end
  end

  def flag
    @point = Point.find(params[:id])
    @point.flag_by_user(current_user)

    respond_to do |format|
      format.html { redirect_to(comments_url) }
      format.js {
        render :update do |page|
          if current_user.is_admin?
            page.replace_html "point_report_#{@point.id}", render(:partial => "points/report_content", :locals => {:point => @point})
          else
            page.replace_html "point_report_#{@point.id}", "<div class='warning_inline'>#{tr("Thanks for bringing this to our attention", "controller/points")}</div>"
          end
        end        
      }
    end    
  end  

  def abusive
    @point = Point.find(params[:id])
    @point.do_abusive
    @point.delete!
    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace_html "point_flag_#{@point.id}", "<div class='warning_inline'>#{tr("The content has been deleted and a warning sent", "controller/points")}</div>"
        end        
      }
    end    
  end

  def not_abusive
    @point = Point.find(params[:id])
    @point.update_attribute(:flags_count, 0)
    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace_html "point_flag_#{@point.id}",""
        end        
      }
    end    
  end

  # DELETE /points/1
  def destroy
    @point = Point.find(params[:id])
    if @point.user_id != current_user.id and not current_user.is_admin?
      flash[:error] = tr("Access denied", "controller/points")
      redirect_to(@point)
      return
    end
    @point.delete!
    ActivityPointDeleted.create(:user => current_user, :point => @point)
    respond_to do |format|
      format.html { redirect_to(points_url) }
    end
  end
  
  private
    def load_endorsement
      @priority = Priority.find(params[:priority_id])    
      @endorsement = nil
      if logged_in? # pull all their endorsements on the priorities shown
        @endorsement = @priority.endorsements.active.find_by_user_id(current_user.id)
      end    
    end  
    
    def get_qualities
      @qualities = nil
      if logged_in? and @points.any? # pull all their qualities on the points shown
        @qualities = PointQuality.find(:all, :conditions => ["point_id in (?) and user_id = ? ", @points.collect {|c| c.id},current_user.id])
      end    
    end    
    
end
