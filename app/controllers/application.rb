# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  #protect_from_forgery  #:secret => '049ceb982d1b6b17b968554ed1a94c03'

  include FacebookerAuthentication::Controller

  before_filter :facebook_login_required, :except => :utils
  #ensure_application_is_installed_by_facebook_user
  ensure_authenticated_to_facebook

  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
end