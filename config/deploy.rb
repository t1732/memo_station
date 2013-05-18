set :application, "memo_station"
set :repository, "file:///var/svn/#{application}/trunk"

role :web, "localhost"
role :app, "localhost"
role :db,  "localhost", :primary => true

set :deploy_to, "/var/www/#{application}"
set :user, "deploy"
set :use_sudo, false
