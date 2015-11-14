class Article < ActiveRecord::Base
  acts_as_taggable

  default_scope { order(arel_table[:updated_at].desc) }

  before_validation :on => :create do
    self.tag_list = normalized_tag_list
    true
  end

  before_validation do
    if changes.has_key?(:title)
      self.title = string_normalize(title)
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
        "title"      => string_normalize(title),
        "tag_list"   => normalized_tag_list,
        "created_at" => created_at,
        "updated_at" => updated_at,
      })
  end

  private

  # acts_as_taggable の不具合で Foo と foo が混在する場合があるため
  def normalized_tag_list
    ActsAsTaggableOn::TagListParser.parse(tag_list.uniq(&:downcase).sort)
  end

  concerning :EmacsSupport do
    included do
      cattr_accessor(:text_separator) { "--text follows this line--" }
      delegate :string_normalize, :to => "self.class"
    end

    class_methods do
      def text_post(str)
        "".tap do |out|
          elems = text_to_array(str)
          logger.debug(elems)
          out << "個数: #{elems.size}\n"
          out << "#{elems.inspect}\n" if $DEBUG
          out << elems.collect { |e| text_post_one(e) }.join("\n")
        end
      end

      def string_normalize(str)
        str.to_s.gsub(/[[:space:]]/, " ").squish
      end

      def separated_text_format(all)
        [
          separator,
          all.collect(&:to_text).join(separator),
          separator,
        ].join
      end

      private

      def text_post_one(str)
        attrs = text_parse(str)

        old_tag_list = ""
        if attrs[:id]
          article = find(attrs[:id])
          pre_article = article.dup # cloneはだめ
          old_tag_list = article.tag_list
        else
          article = new
        end
        article.attributes = attrs.slice(:title, :body, :tag_list)

        save_p = article.new_record?
        save_p ||= !article.same_content?(pre_article)
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
          article.destroy!
          delmark = "D"
        end

        "#{mark + delmark} [#{article.id}] #{article.title} #{errors}".strip
      end

      def text_resolve?(str)
        str.match(/^Title:/i) && str.match(/^Tag:/i)
      end

      def text_to_array(text)
        text.split(/^-{80,}$/).find_all {|article| text_resolve?(article) }
      end

      def separator
        @separator ||= "-" * 80 + "\n"
      end

      def text_parse(str)
        {}.tap do |e|
          str = str.force_encoding("UTF-8")
          if md = str.match(/^Id:\s*(?<id>\d+)$/i)
            e[:id] = md[:id]
          end
          if md = str.match(/^Title:(?<title>.+)$/i)
            e[:title] = string_normalize(md[:title])
          end
          if md = str.match(/^Tag:(?<tag_list>.+)$/i)
            e[:tag_list] = string_normalize(md[:tag_list])
          end
          if md = str.match(/^#{text_separator}\n(?<body>.*)\z/mi)
            e[:body] = md[:body]
          end
        end
      end
    end

    def same_content?(other)
      title == other.title && body == other.body
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

  concerning :Task do
    class_methods do
      # データ移行用
      #
      # production -> staging
      #
      #   rails runner -e production 'Article.data_export'
      #   cp db/production_marshal.bin db/staging_marshal.bin
      #   rails runner -e staging 'Article.data_import'
      #
      # production -> production
      #
      #   rails runner -e production 'Article.data_export'
      #   rails runner -e production 'Article.data_import'
      #
      def data_export
        rows = all.order(:id).collect(&:to_h)
        bin = Marshal.dump(rows)
        marshal_file.write(bin)

        # check
        rows2 = Marshal.load(marshal_file.read)
        if rows2 != rows
          raise "ERROR"
        end
        p "OK"
      end

      def data_import
        raise if Rails.env.production?

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

        # check
        rows.each do |row|
          article = find(row["id"])
          if article.to_h != row
            p row
            p article.to_h
            raise
          end
        end
        p "OK"
      end

      private

      def marshal_file
        Rails.root.join("db/#{Rails.env}_marshal.bin")
      end
    end
  end
end
