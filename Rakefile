# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/switchtower.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

namespace "db" do
  desc "テーブル名の一覧表示(レコード数も一緒に表示)"
  task :table_list => :environment do
    require "table_formatter"
    records = ActiveRecord::Base.connection.instance_eval {
      tables.collect {|table|
        {:table => table, :count => select_value("SELECT count(*) FROM #{table}")}
      }
    }
    records.table_format({
        :method => :to_s,
        :select => [:table, :count],
        :as => {:table => "テーブル名", :count => "レコード数"}
      }).display
  end
end
