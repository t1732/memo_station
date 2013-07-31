# -*- coding: utf-8 -*-

module Emacsen
  extend ActiveSupport::Concern

  included do
    cattr_accessor(:text_separator) { "--text follows this line--" }
  end

  module ClassMethods
    # Emacsからポストできる正しいテキストかを確認する
    def text_resolve?(str)
      str.include?("Title:") && str.include?("Tag:")
    end

    # ポストされたテキストから使えるものだけを抽出する
    def text_post_cleanup(strs)
      strs.split(/^-{80,}$/).find_all{|article|text_resolve?(article)}
    end

    # ポストしたテキストをまとめて処理する
    def text_post(strs)
      out = ""
      articles = text_post_cleanup(strs)
      out << "個数: #{articles.size}\n"
      out << "#{articles.inspect}\n" if $DEBUG
      logger.debug(articles)
      articles.each{|article|
        out << text_post_one(article)
      }
      out
    end

    # 一つの記事だけを処理する
    def text_post_one(str)
      attrs = attributes_for(str)

      old_tag_list = ""
      if attrs[:id]
        article = Article.find(attrs[:id])
        pre_article = article.dup # cloneはだめ
        old_tag_list = article.tag_list
      else
        article = Article.new
      end
      article.attributes = attrs.slice(:title, :body, :tag_list)

      save_p = article.new_record?
      save_p ||= !article.content_equal?(pre_article)
      save_p ||= old_tag_list.sort != article.tag_list.sort

      errors = ""
      mark = " "
      if save_p
        mark = article.new_record? ? "A" : "U"
        if article.save
        else
          mark = "E"
          errors = article.errors.full_messages.join(" ")
        end
      end

      delmark = " "
      if article.tag_list.include?("_del")
        article.destroy
        delmark = "D"
      end

      "#{mark + delmark} [#{article.id}] #{article.title} #{errors}".rstrip + "\n"
    end

    def collection_to_txt(records)
      [
        separator,
        records.collect(&:to_text).join(separator),
        separator,
      ].join
    end

    private

    def separator
      @separator ||= "-" * 80 + "\n"
    end

    def attributes_for(str)
      {}.tap do |attrs|
        str = str.force_encoding("UTF-8")
        if md = str.match(/^Id:\s*(\d+)$/i)
          attrs[:id] = md.captures.first.to_i
        end
        if md = str.match(/^Title:(.+)$/i)
          attrs[:title] = md.captures.first.strip
        end
        if md = str.match(/^Tag:(.+)$/i)
          attrs[:tag_list] = md.captures.first.strip
        end
        if md = str.match(/^#{text_separator}\n(.*)\z/mi)
          attrs[:body] = md.captures.first
        end
      end
    end
  end

  # other の tag_names は常に空。比較はできないので注意。
  def content_equal?(other)
    [
      title.to_s.strip == other.title.to_s.strip,
      body.to_s.strip == other.body.to_s.strip,
    ].all?
  end

  def to_text
    str = []
    str << "Id: #{id}"
    str << "Title: #{title}"
    str << "Tag: #{tag_list}"
    str << "Date: #{created_at.to_s(:ymdhm)}"
    str << text_separator
    str << "#{body}"
    str.join("\n") + "\n"
  end
end
