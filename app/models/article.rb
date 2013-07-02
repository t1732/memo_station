# -*- coding: utf-8 -*-

class Article < ActiveRecord::Base
  include EmacsMethods
  acts_as_taggable

  # attr_accessible :title, :body, :tag_list

  default_scope { order(arel_table[:updated_at].desc) }

  before_validation :normalize
  def normalize
    if changes.has_key?("title")
      self.title = title.to_s.squish.presence
    end
    if changes.has_key?("body")
      self.body = body.to_s.strip.presence
    end
    true
  end

  # validates :tag_list, :presence => true, :format => %r/\A[^%{}\#\^\$]+\z/i
  validates :tag_list, :presence => true
  validates :title, :presence => true, :uniqueness => true
  # validates :body, :allow_blank => true
end

if $0 == __FILE__
  Article.logger = ActiveSupport::BufferedLogger.new(STDOUT)
  ActiveSupport::LogSubscriber.colorize_logging = false
  Article.delete_all
  ActsAsTaggableOn::Tagging.delete_all
  ActsAsTaggableOn::Tag.delete_all

  str = "escape_char = '%'\n[\n  \"\\n%{foo}\",\n  \"\\t%{foo}\",\n  \"\\%{foo}\",\n  \"%{foo}\",\n  \"\#{escape_char}%{foo}\",\n].each{|str|\n  p [str, (str.match(/(?:[^\#{escape_char}]|^)%\\{(\\w+)\\}/) ? \"OK\" : \"\")]\n}\n\n# [^\#{escape_char}] と書けば \"%%{foo}\" は無視されるが、\n# \"%{foo}\" の先頭が何にもマッチしないため通らなくなる\n# そこで「% 以外」または「行頭」という設定が必要になり、\n# 結果、(?:[^\#{escape_char}]|^) と書けばよい\n\nしかし、%%{foo} と書いたときは %%{foo} を残すのではなく %{foo} に変換したいという場合は次のように書く\n\nescape_char = '%'\n[\n  \" %{foo}\",\n  \"\\n%{foo}\",\n  \"%{foo}\",\n  \"\#{escape_char}%{foo}\",\n].each{|str|\n  str3 = str.gsub(/(\#{escape_char}?(%\\{(\\w+)\\}))/){|str2|\n    escaped_match, match, key = Regexp.last_match.captures\n    if escaped_match.match(/\\A\#{escape_char}%/)\n      match\n    else\n      \"【\#{key}】\"\n    end\n  }\n  p [str, str3]\n}"

  a = Article.new(:title => rand.to_s, :body => "str")
  a.tag_list = "a b"
  a.save!

  # a.tag_list = ""
  # a.save!

  # p a.tag_list.to_s
  # Article.related_tags_for("tags",
  # p Article.tagged_with("c b").order("id asc").limit(2).collect{|r|[r.id, r.tag_list.to_s]}
  # p Article.tagged_with(" ").order("id asc").limit(2).collect{|r|[r.id, r.tag_list.to_s]}
end
