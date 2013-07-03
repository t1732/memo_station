# -*- coding: utf-8 -*-
require "capistrano/ext/multistage"
require "bundler/capistrano"
require "etc"

set :default_stage, :production

set :application, "memo_station"
set :repository, "file://#{Pathname(__FILE__).dirname.dirname.expand_path}"
set :group_writable, false      # chmod g+w されたときにエラーがでるんでしかたなく
set :scm, :git
set :user, Etc.getlogin

# set :bundle_flags, "--deployment --verbose"
set :git_shallow_clone, 1

namespace :deploy do
  task(:start){}
  task(:stop){}
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end
end
