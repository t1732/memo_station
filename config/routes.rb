ActionController::Routing::Routes.draw do |map|
  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.

  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # You can have the root of your site routed by hooking up ''
  # -- just remember to delete public/index.html.
  map.connect '', :controller => "article"

  map.connect "search",        :controller => "article", :action => "search"
  map.connect "new",           :controller => "article", :action => "new"
  map.connect "edit/:id",      :controller => "article", :action => "edit"
  map.connect "show/:id",      :controller => "article", :action => "show"
  map.connect "list",          :controller => "article", :action => "list"
  map.connect "rss",           :controller => "article", :action => "rss"
  map.connect "bookmarklet",   :controller => "article", :action => "bookmarklet"
  map.connect "graph",         :controller => "article", :action => "graph"
  map.connect "export",        :controller => "article", :action => "export"
  map.connect "bookmark",      :controller => "article", :action => "bookmark"
  map.connect "recent_viewed", :controller => "article", :action => "recent_viewed"
  map.connect "most_viewed",   :controller => "article", :action => "most_viewed"

  map.connect "login",       :controller => "account",  :action => "login"
  map.connect "logout",      :controller => "account",  :action => "logout"
  map.connect "signup",      :controller => "account",  :action => "signup"
  map.connect "home",        :controller => "mypage"
  map.css "css/:action",     :controller => "stylesheet"
  map.profile "profile/:loginname", :controller => "user_info",  :action => "profile"
  map.connect "#{SEARCH_PLUGIN_NAME}.src",     :controller => "article", :action => "search_plugin_source"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
