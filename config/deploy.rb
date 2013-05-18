# -*- coding: utf-8 -*-
require "capistrano/ext/multistage"
require "bundler/capistrano"
# require "rvm/capistrano"

# set :stage, "production"

set :application, "memo_station"
set :repository, Pathname("~/src/#{application}").expand_path.to_s
set :group_writable, false      # chmod g+w されたときにエラーがでるんでしかたなく
set :scm, :git

set :bundle_flags, "--deployment --verbose"
# set :bundle_flags, "--verbose"

# set :git_shallow_clone, 1
# set :deploy_via, :remote_cache

# RVMを利用時の設定
# $:.unshift(File.expand_path('./lib', ENV['rvm_path']))
# set :rvm_ruby_string, '1.9.3'
# set :rvm_type, :system

namespace :deploy do
  task(:start){}
  task(:stop){}
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end
end
