# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Enable threaded mode
# config.threadsafe!

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

#Amazon web services key
KEY_ID = 
ASSOCIATES_ID = 
SECRET_KEY_ID = 
LOCALE = 'us'
MAX_ISO_SEARCH_NUMBER = 15
DVDFLEX_ENV='prod'
# see http://caboo.se/doc/classes/ActionController/RequestForgeryProtection/ClassMethods.html
config.action_controller.allow_forgery_protection = false
# Netflix API: 2ry3c4w7xvvjg6qqfky93y6m   Shared Secret: pXmt4pWG8u