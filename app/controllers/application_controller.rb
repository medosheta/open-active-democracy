# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'will_paginate/array'

class ApplicationController < ActionController::Base
  include Tr8n::CommonMethods
  include AuthenticatedSystem
  include FaceboxRender

  include Facebooker2::Rails::Controller

  require_dependency "activity.rb"
  require_dependency "blast.rb" 
  require_dependency "relationship.rb"   
  require_dependency "capital.rb"

#  rescue_from ActionController::InvalidAuthenticityToken, :with => :bad_token

  helper :all # include all helpers, all the time
  
  # Make these methods visible to views as well
  helper_method :current_facebook_user, :government_cache, :current_partner, :current_user_endorsements, :current_priority_ids, :current_following_ids, :current_ignoring_ids, :current_following_facebook_uids, :current_government, :current_tags, :facebook_session, :is_robot?, :js_help
  
  # switch to the right database for this government
  before_filter :check_for_localhost
  before_filter :check_subdomain
  before_filter :check_geoblocking

  before_filter :session_expiry
  before_filter :update_activity_time

  before_filter :load_actions_to_publish, :unless => [:is_robot?]
#  before_filter :check_facebook, :unless => [:is_robot?]
    
  before_filter :check_blast_click, :unless => [:is_robot?]
  before_filter :check_priority, :unless => [:is_robot?]
  before_filter :check_referral, :unless => [:is_robot?]
  before_filter :check_suspension, :unless => [:is_robot?]
  before_filter :update_loggedin_at, :unless => [:is_robot?]
  before_filter :init_tr8n
  before_filter :check_google_translate_setting
  before_filter :check_missing_user_parameters, :except=>[:destroy]

  before_filter :setup_inline_translation_parameters

  layout :get_layout

  protect_from_forgery

  protected

  JS_ESCAPE_MAP = {
        '\\'    => '\\\\',
        '</'    => '<\/',
        "\r\n"  => '\n',
        "\n"    => '\n',
        "\r"    => '\n',
        '"'     => '\\"',
        "'"     => "\\'" }
  
  def action_cache_path
    params.merge({:geoblocked=>@geoblocked, :host=>request.host, :country_code=>@country_code,
                  :locale=>session[:locale], :google_translate=>session[:enable_google_translate],
                  :have_shown_welcome=>session[:have_shown_welcome], 
                  :last_selected_language=>cookies[:last_selected_language],
                  :flash=>flash.map {|k,v| "#{v}" }.join.parameterize})
  end

  def do_action_cache?
    if logged_in?
      false
    elsif request.format.html?
      true
    else
      false
    end
  end
  
  def check_missing_user_parameters
    if logged_in? and Government.current.layout == "better_reykjavik" and controller_name!="settings"
      unless current_user.email and current_user.my_gender and current_user.post_code and current_user.age_group
        flash[:notice] = "Please make sure you have registered all relevant information about you for this website."
        redirect_to :controller=>"settings"
      end
    end
  end

  def check_for_localhost
    if Rails.env.development?
      Thread.current[:localhost_override] = "#{request.host}:#{request.port}"
    end
  end

  def session_expiry
    return if controller_name == "sessions"
    Rails.logger.info("Session expires at #{session[:expires_at]}")
    if session[:expires_at]
      @time_left = (session[:expires_at] - Time.now).to_i
      if current_user and not current_facebook_user
        unless @time_left > 0
          Rails.logger.info("Resetting session")
          reset_session
          flash[:error] = tr("Your session has expired, please login again.","session")
          redirect_to '/'
        end
      end
    end
  end
  
  def update_activity_time
    if current_user and current_user.is_admin?
      session[:expires_at] = 6.hours.from_now
    else
      session[:expires_at] = 1.hour.from_now
    end
  end

  def setup_inline_translation_parameters
    @inline_translations_allowed = false
    @inline_translations_enabled = false

    if logged_in? and Tr8n::Config.current_user_is_translator?
      unless Tr8n::Config.current_translator.blocked?
        @inline_translations_allowed = true
        @inline_translations_enabled = Tr8n::Config.current_translator.enable_inline_translations?
      end
    elsif logged_in?
      @inline_translations_allowed = Tr8n::Config.open_registration_mode?
    end

    @inline_translations_allowed = true if Tr8n::Config.current_user_is_admin?
  end
        
  def unfrozen_instance(object)
    eval "#{object.class}.where(:id=>object.id).first"
  end
        
  def escape_javascript(javascript)
    if javascript
      javascript.gsub(/(\\|<\/|\r\n|[\n\r"'])/) { JS_ESCAPE_MAP[$1] }
    else
      ''
    end
  end  

  # Will either fetch the current partner or return nil if there's no subdomain
  def current_partner
    if request.host.include?("betrireykjavik")
      if request.subdomains.size == 0 or request.host.include?(current_government.domain_name) or request.subdomains.first == 'www'
        if (controller_name=="home" and action_name=="index") or
           Rails.env.development? or
           request.host.include?("betrireykjavik") or
           self.class.name.downcase.include?("tr8n") or
           ["endorse","oppose","authorise_google","windows","yahoo"].include?(action_name)
          @current_partner = nil
          Partner.current = @current_partner
          Rails.logger.info("No partner")
          return nil
        else
          redirect_to "/welcome"
        end
      else
        @current_partner ||= Partner.find_by_short_name(request.subdomains.first)
        Partner.current = @current_partner
        Rails.logger.info("Partner: #{@current_partner.short_name}")
        return @current_partner
      end
    else
       if request.subdomains.size == 0 or request.host == current_government.base_url or request.subdomains.first == 'www'
        if (controller_name=="home" and action_name=="index") or
           Rails.env.development? or
           request.host.include?("betrireykjavik") or
           self.class.name.downcase.include?("tr8n") or
           ["endorse","oppose","authorise_google","windows","yahoo"].include?(action_name)
          @current_partner = nil
          Partner.current = @current_partner
          Rails.logger.info("No partner")
          return nil
        else
          redirect_to "/welcome"
        end
      else
        @current_partner ||= Partner.find_by_short_name(request.subdomains.first)
        Partner.current = @current_partner
        Rails.logger.info("Partner: #{@current_partner.short_name}")
        return @current_partner
      end
    end
  end
  
  def check_geoblocking
    @country_code = Thread.current[:country_code] = (session[:country_code] ||= GeoIP.new(Rails.root.join("lib/geoip/GeoIP.dat")).country(request.remote_ip)[3]).downcase
    @country_code = "is" if @country_code == nil or @country_code == "--"
    @iso_country = Tr8n::IsoCountry.find_by_code(@country_code.upcase)
    Rails.logger.info("Geoip country: #{@country_code} - locale #{session[:locale]} - #{current_user ? (current_user.email ? current_user.email : current_user.login) : "Anonymous"}")
    Rails.logger.info(request.user_agent)
    if Partner.current and Partner.current.geoblocking_enabled
      logged_in_user = current_user
      unless Partner.current.geoblocking_disabled_for?(@country_code)
        Rails.logger.info("Geoblocking enabled")
        @geoblocked = true unless current_user and current_user.is_admin?
      end
      if logged_in_user and logged_in_user.geoblocking_disabled_for?(Partner.current)
        Rails.logger.info("Geoblocking disabled for user #{logged_in_user.login}")
        @geoblocked = false
      end
    end
    if @geoblocked
      unless session["have_shown_geoblock_warning_#{@country_code}"]
        flash.now[:notice] = tr("This part of the website is only open for viewing in your country.","geoblocking")
        session["have_shown_geoblock_warning_#{@country_code}"] = true
      end
    end
  end
  
  def current_locale
    if params[:locale]
      session[:locale] = params[:locale]
      cookies.permanent[:last_selected_language] = session[:locale]
      Rails.logger.debug("Set language from params")
    elsif not session[:locale]
      if cookies[:last_selected_language]
        session[:locale] = cookies[:last_selected_language]
        Rails.logger.debug("Set language from cookie")
      elsif @iso_country and not @iso_country.languages.empty?
        session[:locale] =  @iso_country.languages.first.locale
        Rails.logger.debug("Set language from geoip")
      elsif Partner.current and Partner.current.default_locale
        session[:locale] = Partner.current.default_locale
        Rails.logger.debug("Set language from partner")
      else
        session[:locale] = tr8n_user_preffered_locale
        Rails.logger.debug("Set language from tr8n")
      end
    else
      Rails.logger.debug("Set language from session")
    end
    session_locale = session[:locale]
    if ENABLED_I18_LOCALES.include?(session_locale)
      I18n.locale = session_locale
    else
      session_locale = session_locale.split("-")[0] if session_locale.split("-").length>1
      I18n.locale = ENABLED_I18_LOCALES.include?(session_locale) ? session_locale : "en"
    end
    tr8n_current_locale = session[:locale]
  end

  def check_google_translate_setting
    if params[:gt]
      if params[:gt]=="1"
        session[:enable_google_translate] = true
      else
        session[:enable_google_translate] = nil
      end
    end
    
    @google_translate_enabled_for_locale = tr8n_current_google_language_code
  end
  
  def get_layout
    return false if not is_robot? and not current_government
    return "basic" if not Government.current
    return Government.current.layout
  end

  def current_government
    return @current_government if @current_government
    @current_government = Rails.cache.read('government')
    if not @current_government
      @current_government = Government.last
      if @current_government
        @current_government.update_counts
        Rails.cache.write('government', @current_government, :expires_in => 15.minutes) 
      else
        return nil
      end
    end
    Government.current = @current_government
    return @current_government
  end
  
  def current_user_endorsements
		@current_user_endorsements ||= current_user.endorsements.active.by_position.paginate(:include => :priority, :page => session[:endorsement_page], :per_page => 25)
  end
  
  def current_priority_ids
    return [] unless logged_in? and current_user.endorsements_count > 0
    @current_priority_ids ||= current_user.endorsements.active_and_inactive.collect{|e|e.priority_id}
  end  
  
  def current_following_ids
    return [] unless logged_in? and current_user.followings_count > 0
    @current_following_ids ||= current_user.followings.up.collect{|f|f.other_user_id}
  end
  
  def current_following_facebook_uids
    return [] unless logged_in? and current_user.followings_count > 0 and current_user.has_facebook?
    @current_following_facebook_uids ||= current_user.followings.up.collect{|f|f.other_user.facebook_uid}.compact
  end  
  
  def current_ignoring_ids
    return [] unless logged_in? and current_user.ignorings_count > 0
    @current_ignoring_ids ||= current_user.followings.down.collect{|f|f.other_user_id}    
  end
  
  def current_tags
    return [] unless current_government.is_tags?
    @current_tags ||= Rails.cache.fetch('Tag.by_endorsers_count.all') { Tag.by_endorsers_count.all }
  end

  def load_actions_to_publish
    @user_action_to_publish = flash[:user_action_to_publish] 
    flash[:user_action_to_publish]=nil
  end  
  
  def check_suspension
    if logged_in? and current_user and current_user.status == 'suspended'
      self.current_user.forget_me if logged_in?
      cookies.delete :auth_token
      reset_session
      flash[:notice] = "This account has been suspended."
      redirect_back_or_default('/')
      return  
    end
  end
  
  # they were trying to endorse a priority, so let's go ahead and add it and take htem to their priorities page immediately    
  def check_priority
    return unless logged_in? and session[:priority_id]
    @priority = Priority.find(session[:priority_id])
    @value = session[:value].to_i
    if @priority
      if @value == 1
        @priority.endorse(current_user,request,current_partner,@referral)
      else
        @priority.oppose(current_user,request,current_partner,@referral)
      end
    end  
    session[:priority_id] = nil
    session[:value] = nil
  end
  
  def update_loggedin_at
    return unless logged_in?
    return unless current_user.loggedin_at.nil? or Time.now > current_user.loggedin_at+30.minutes
    begin
      User.find(current_user.id).update_attribute(:loggedin_at,Time.now)
    rescue
    end
  end

  def check_blast_click
    # if they've got a ?b= code, log them in as that user
    if params[:b] and params[:b].length > 2
      @blast = Blast.find_by_code(params[:b])
      if @blast and not logged_in?
        self.current_user = @blast.user
        @blast.increment!(:clicks_count)
      end
      redirect = request.path_info.split('?').first
      redirect = "/" if not redirect
      redirect_to redirect
      return
    end
  end

  def check_subdomain
    if not current_government
      redirect_to :controller => "install"
      return
    end
    if not current_partner and Rails.env == 'production' and request.subdomains.any? and not ['www','dev'].include?(request.subdomains.first) and current_government.base_url != request.host
      redirect_to 'http://' + current_government.base_url + request.path_info
      return
    end    
  end
  
  def check_referral
    if not params[:referral_id].blank?
      @referral = User.find(params[:referral_id])
    else
      @referral = nil
    end    
  end  
  
  # if they're logged in with our account, AND connected with facebook, but don't have their facebook uid added to their account yet
  def check_facebook 
    if logged_in? and current_facebook_user
      unless current_user.facebook_uid
        @user = User.find(current_user.id)
        if not @user.update_with_facebook(current_facebook_user)
          return
        end
        if not @user.activated?
          @user.activate!
        end      
        @current_user = User.find(current_user.id)
        flash.now[:notice] = tr("Your account is now synced with Facebook. In the future, to sign in, simply click the big blue Facebook button.", "controller/application", :government_name => tr(current_government.name,"Name from database"))
      end
    end      
  end
  
  def is_robot?
    return true if request.format == 'rss' or params[:controller] == 'pictures'
    request.user_agent =~ /\b(Baidu|Gigabot|Googlebot|libwww-perl|lwp-trivial|msnbot|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg)\b/i
  end
  
  def no_facebook?
    return false if logged_in? and current_facebook_user
    return true
  end
  
  def bad_token
    flash[:error] = tr("Sorry, that last page already expired. Please try what you were doing again.", "controller/application")
    respond_to do |format|
      format.html { redirect_to request.referrer||'/' }
      format.js { redirect_from_facebox(request.referrer||'/') }
    end
  end
  
  def fb_session_expired
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session    
    flash[:error] = tr("Your Facebook session expired.", "controller/application")
    respond_to do |format|
      format.html { redirect_to '/portal/' }
      format.js { redirect_from_facebox(request.referrer||'/') }
    end    
  end
  
  def js_help
    JavaScriptHelper.instance
  end

  class JavaScriptHelper
    include Singleton
    include ActionView::Helpers::JavaScriptHelper
  end  
end

module FaceboxRender
   
  def render_to_facebox( options = {} )
    options[:template] = "#{default_template_name}" if options.empty?

    action_string = render_to_string(:action => options[:action], :layout => "facebox") if options[:action]
    template_string = render_to_string(:template => options[:template], :layout => "facebox") if options[:template]

    render :update do |page|
      page << "jQuery.facebox(#{action_string.to_json})" if options[:action]
      page << "jQuery.facebox(#{template_string.to_json})" if options[:template]
      page << "jQuery.facebox(#{(render :partial => options[:partial]).to_json})" if options[:partial]
      page << "jQuery.facebox(#{options[:html].to_json})" if options[:html]

      if options[:msg]
        page << "jQuery('#facebox .content').prepend('<div class=\"message\">#{options[:msg]}</div>')"
      end
      page << render(:partial => "shared/javascripts_reloadable")
      
      yield(page) if block_given?

    end
  end
    
end
