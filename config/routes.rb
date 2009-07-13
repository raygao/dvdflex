ActionController::Routing::Routes.draw do |map|
  map.resources :torrents, :member => {:show_dvd => :get, :add => [:get, :post]}

  # this adds a new member route 'test_ajax' to the 'listings' controller.
  # use 'rake routes' to verify.

  map.root :controller => "listings", :action => "index"

  map.resources :listings, :collection => { :showuser => :get, :test_ajax => :get  }
  map.resources :dvds, :collection => {:preprocess => :get, :search => [:get, :post],
    :regenerate => [:get, :post]}
  map.resources :utils, :collection => {
    :invite => [:get, :post],
    :export => [:get, :post],
    :doexport => [:get, :post],
    :confirmed => [:get, :post],
    :welcome => [:get, :post],
    :news => [:get, :post]
  }
 
  map.resources :users do |users|
    users.resources :listings
  end

  # routing info, see http://travisonrails.com/posts/tagged-with/routes

  map.connect ':controller/:action'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  map.connect '//', :controller => 'listings', :format => 'fbml'
  # this solves the export problem.
  map.connect '//utils/doexport', :controller => 'utils', :action => 'doexport'
  #map.connect '//utils/welcome', :controler => 'utils', :action => 'welcome'
end

