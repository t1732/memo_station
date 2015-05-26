# This migration comes from acts_as_taggable_on_engine (originally 4)
class ArticlesTimestampsIsNotNull < ActiveRecord::Migration
  def change
    change_column :articles, :created_at, :datetime, :null => false
    change_column :articles, :updated_at, :datetime, :null => false
  end
end
