# -*- coding: utf-8 -*-

module Emacsen
  extend ActiveSupport::Concern

  module ClassMethods
    # Emacsからポストできる正しいテキストかを確認する
    def text_format_ok?(article_str)
      article_str.include?("Title:") && article_str.include?("Tag:")
    end

    # ポストされたテキストから使えるものだけを抽出する
    def text_post_cleanup(articles_str)
      articles = articles_str.split(/^-{80,}$/)
      articles.find_all{|article|text_format_ok?(article)}
    end

    # ポストしたテキストをまとめて処理する
    def text_post(articles_str)
      out = ""
      articles = text_post_cleanup(articles_str)
      out << "個数: #{articles.size}\n"
      out << "#{articles.inspect}\n" if $DEBUG
      logger.debug(articles)
      articles.each{|article|
        out << text_post_one(article)
      }
      out
    end

    # 一つの記事だけを処理する
    def text_post_one(article_str)
      article_str = article_str.force_encoding("UTF-8")

      if md = article_str.match(/^Id:\s*(\d+)$/i)
        id = md.captures.first.to_i
      end
      if md = article_str.match(/^Title:(.+)$/i)
        title = md.captures.first.strip
      end
      if md = article_str.match(/^Tag:(.+)$/i)
        tag = md.captures.first.strip
      end
      if md = article_str.match(/^--text follows this line--\n(.*)\z/mi)
        body = md.captures.first
      end
      if id
        article = Article.find(id)
        pre_article = article.dup # cloneはだめ
      else
        article = Article.new
      end
      article.attributes = {:title => title, :body => body}
      article.tag_list = tag
      if article.new_record?
        do_save = true
      else
        # Rails.logger.debug(article.attributes.pretty_inspect)
        # Rails.logger.debug(pre_article.attributes.pretty_inspect)
        unless article.contents_equal?(pre_article)
          do_save = true
        end
      end
      if do_save
        if article.new_record?
          status = "A"
        else
          status = "M"
        end
        if article.save
          save_result = "OK"
        else
          save_result = "Error #{article.errors.full_messages}"
        end
      else
        status = " "
      end
      "#{status} [#{article.id}] #{article.title} #{save_result}".rstrip + "\n"
    end

    def collection_to_txt(records)
      separator = "-" * 80 + "\n"
      output = separator + records.collect{|article|article.to_text}.join(separator) + separator
      # output + "-- content end --\n"
    end
  end

  # other の tag_names は常に空。比較はできないので注意。
  def contents_equal?(other)
    title.to_s.strip == other.title.to_s.strip && body.to_s.strip == other.body.to_s.strip
  end

  def to_text
    str = []
    str << "Id: #{id}"
    str << "Title: #{title}"
    str << "Tag: #{tag_list}"
    str << "Date: #{created_at}"
    str << "--text follows this line--"
    str << "#{body}"
    str.join("\n") + "\n"
  end
end
