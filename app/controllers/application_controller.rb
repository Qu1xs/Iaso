class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # include ApplicationHelper
  helper_method :current_user, :logged_in?, :require_login

  def logged_in?
    current_user
  end

  def current_user
    @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
  end

  def require_login
    if !logged_in?
      redirect_to root_path
    end
  end

  def permission_required
    unless @user = current_user
      flash[:alerts] = ["You don't have permission"]
      redirect_to root_path
    end 
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def render_not_found
    render :file => "#{RAILS_ROOT}/public/404.html",  :status => 404
  end

end