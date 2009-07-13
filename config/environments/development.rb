# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

#Amazon web services key
KEY_ID = 
ASSOCIATES_ID = 
SECRET_KEY_ID = 
LOCALE = 'us'
MAX_ISO_SEARCH_NUMBER = 15
DVDFLEX_ENV='dev'
# see http://caboo.se/doc/classes/ActionController/RequestForgeryProtection/ClassMethods.html
config.action_controller.allow_forgery_protection = false
# Netflix API: 2ry3c4w7xvvjg6qqfky93y6m   Shared Secret: pXmt4pWG8u
