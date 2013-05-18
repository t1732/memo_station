# -*- coding: utf-8 -*-
set :user, "ikeda"

role :web, "localhost"
role :app, "localhost"
role :db,  "localhost", :primary => true

set :rails_env, "production"
set :deploy_to, "/var/www/#{application}_#{rails_env}"

default_run_options.update(:env => {"RAILS_ENV" => rails_env})

# task :ok do
#   run "env"
# end

# after "deploy:setup", "change_to_user_permission"
# task :change_to_user_permission, :roles => :app do
#   sudo "chown -R #{user}:wheel #{deploy_to}"
#   sudo "chmod -R a+rw #{deploy_to}"
#   sudo "chmod -R o-w #{deploy_to}"
# end

# ssh_options[:forward_agent] = true
# set :scm_verbose, true
# set :deploy_via, :remote_cache
# set :git_shallow_clone, 1

# deploy ユーザーが bundle コマンドを参照できないエラーがこれで治る
# http://beginrescueend.com/integration/capistrano/
# $:.unshift(File.expand_path('./lib', ENV['rvm_path']))
# require "rvm/capistrano"
