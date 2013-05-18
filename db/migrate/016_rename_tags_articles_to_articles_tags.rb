class RenameTagsArticlesToArticlesTags < ActiveRecord::Migration
  def self.up
    rename_table :tags_articles, :articles_tags
  end

  def self.down
    rename_table :articles_tags, :tags_articles
  end
end
