class WidgetsController < ApplicationController
  
  def index
    @page_title = tr("Widgets for your blog or website", "controller/widgets", :government_name => tr(current_government.name,"Name from database"))
    respond_to do |format|
      format.html
    end
  end
  
  def priorities
    @page_title = tr("Put {government_name} priorities on your website", "controller/widgets", :government_name => tr(current_government.name,"Name from database"))
    if logged_in?
      @widget = Widget.new(:controller_name => "priorities", :user => current_user, :action_name => "yours")
    else
      @widget = Widget.new(:controller_name => "priorities", :action_name => "top")
    end
    respond_to do |format|
      format.html
    end    
  end
  
  def discussions
    @page_title = tr("Put {government_name} discussions on your website", "controller/widgets", :government_name => tr(current_government.name,"Name from database"))
    if logged_in?
      @widget = Widget.new(:controller_name => "news", :user => current_user, :action_name => "your_discussions")
    else
      @widget = Widget.new(:controller_name => "news", :action_name => "discussions")
    end
    respond_to do |format|
      format.html
    end    
  end
  
  def points
    @page_title = tr("Put {government_name} points on your website", "controller/widgets", :government_name => tr(current_government.name,"Name from database"))    
  end
  
  def preview
    @widget = Widget.new(params[:widget])
    render :layout => false
  end
  
  def preview_iframe
    render :layout => false
  end
  
end
