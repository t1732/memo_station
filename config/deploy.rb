# -*- coding: utf-8 -*-
set :application, "memo_station"
set :repo_url, "file://#{Pathname(__FILE__).dirname.dirname.expand_path}"

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# set :deploy_to, "/var/www/#{fetch(:application)}_production"
set :scm, :git

# set :format, :pretty
# set :log_level, :debug
# set :pty, true

# set :linked_files, %w{config/database.yml}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5

namespace :deploy do

  desc "Restart application"
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :mkdir, "-p", release_path.join("tmp") # <= これを追加する
      execute :touch, release_path.join("tmp/restart.txt")
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, "cache:clear"
      # end
    end
  end

  after :finishing, "deploy:cleanup"
end

# # デプロイ時にDBを初期化するか？
# if false
#   desc "rake db:reset の実行"
#   task :db_reset, :roles => :db do
#     p 1
#     # run "cd #{current_release} && bundle exec rake db:reset --trace"
#   end
#   after "deploy:update", "db_reset"
# end
# 
# # デプロイ時の rake migrate のあとで rake db:seed を実行するか？
# if false
#   desc "rake db:seed"
#   task :db_seed, :roles => :db, :only => { :primary => true } do
#     # run "cd #{current_release} && bundle exec rake db:seed --trace"
#   end
#   after "deploy:migrate", "db_seed"
# end
