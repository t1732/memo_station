# -*- coding: utf-8 -*-

class Article < ActiveRecord::Base
  acts_as_taggable

  default_scope { order(arel_table[:updated_at].desc) }

  before_validation do
    if changes.has_key?(:title)
      self.title = title.to_s.squish.presence
    end
    if changes.has_key?(:body)
      self.body = body.to_s.strip.presence
    end
    true
  end

  with_options(:presence => true) do |o|
    o.validates :title
    o.validates :tag_list
  end

  with_options(:allow_blank => true) do |o|
    o.validates :title, :uniqueness => true
  end

  def to_h
    attributes.merge({
        "title"      => title.to_s.gsub(/\u3000/, " ").squish,
        "tag_list"   => normalized_tag_list,
        "created_at" => created_at,
        "updated_at" => updated_at,
      })
  end

  # acts_as_taggable の不具合で Foo と foo が混在する場合があるため
  def normalized_tag_list
    ActsAsTaggableOn::TagListParser.parse(tag_list.uniq(&:downcase).sort)
  end

  module EmacsSupport
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
        attrs = text_parse(str)

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

      def text_parse(str)
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
  include EmacsSupport

  module Task
    extend ActiveSupport::Concern

    module ClassMethods
      # production -> staging
      # rails runner -e production 'Article.data_export'
      # cp db/production_marshal.bin db/staging_marshal.bin
      # rails runner -e staging 'Article.data_import'
      #
      # production -> production
      # rails runner -e production 'Article.data_export'
      # rails runner -e production 'Article.data_import'
      def data_export
        rows = all.order(:id).collect(&:to_h)
        bin = Marshal.dump(rows)
        marshal_file.open("wb"){|f|f << bin}
        rows2 = Marshal.load(marshal_file.read)
        if rows2 == rows
          p "OK"
        else
          p "ERROR"
        end
      end

      def data_import
        destroy_all
        rows = Marshal.load(marshal_file.read)

        rows.each do |row|
          begin
            create!(row)
          rescue => error
            p row
            p error
            if error.respond_to?(:record)
              p error.record
              p error.record.errors
            end
          end
        end

        rows.each{|row|
          article = find(row["id"])
          if article.to_h == row
          else
            p row
            p article.to_h
            raise
          end
        }
        p "OK"
      end

      def marshal_file
        Rails.root.join("db/#{Rails.env}_marshal.bin")
      end
    end
  end
  include Task
end
