role :web, "localhost"
role :app, "localhost"
role :db,  "localhost", :primary => true

set :rails_env, "production"
set :deploy_to, "/var/www/#{application}_#{rails_env}"

default_run_options.update(:env => {"RAILS_ENV" => rails_env})

after "deploy:setup", "set_permission"
task :set_permission, :roles => :app do
  sudo "chown -R #{user}:wheel #{deploy_to}"
  sudo "chmod -R a+rw #{deploy_to}"
  sudo "chmod -R o-w #{deploy_to}"
end
