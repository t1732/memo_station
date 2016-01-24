class Article < ActiveRecord::Base
  acts_as_taggable

  default_scope { order(arel_table[:updated_at].desc) }

  before_validation on: :create do
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

  with_options(presence: true) do
    validates :title
    validates :tag_list
  end

  with_options(allow_blank: true) do
    validates :title, uniqueness: true
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
      delegate :string_normalize, to: "self.class"
    end

    class_methods do
      def text_post(str)
        "".tap do |out|
          elems = text_to_array(str)
          logger.debug(elems)
          elems2 = elems.collect { |e| text_post_one(e) }.compact
          skip = elems.size - elems2.size
          out << "ポスト数: #{elems.size}, 処理数: #{elems2.size}, skip: #{skip}\n"
          out << "#{elems.inspect}\n" if $DEBUG
          out << elems2.join("\n")
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
        if attrs[:id]
          article = find(attrs[:id])
          if article.same_content?(attrs)
            return
          end
        else
          article = new
        end
        info = text_post_one_save(article, attrs)
        if article.tag_list.include?("_del")
          article.destroy!
          info[:mark] << "D"
        end
        format("%-3s [#{article.id}] #{article.title} #{info[:errors]}", info[:mark]).rstrip
      end

      def text_post_one_save(article, attrs)
        article.attributes = attrs.slice(:title, :body, :tag_list)
        errors = ""
        mark = article.new_record? ? "A" : "U"
        unless article.save
          mark << "E"
          errors = article.errors.full_messages.join(" ")
        end
        {:mark => mark, :errors => errors}
      end

      def text_resolve?(str)
        str.match(/^Title:/i) && str.match(/^Tag:/i)
      end

      def text_to_array(text)
        text.split(/^-{80,}$/).find_all {|e| text_resolve?(e) }
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
            e[:tag_list] = ActsAsTaggableOn::TagListParser.parse(string_normalize(md[:tag_list]))
          end
          if md = str.match(/^#{text_separator}\n(?<body>.*)\z/mi)
            e[:body] = md[:body].strip
          end
        end
      end
    end

    def same_content?(attrs)
      [:title, :body].all? { |key| send(key) == attrs[key] } && tag_list.sort == attrs[:tag_list].sort
    end

    def to_text
      str = []
      str << "Id: #{id}"
      str << "Title: #{title}"
      str << "Tag: #{tag_list}"
      str << "Date: #{created_at.to_s(:ymdhm)}"
      str << text_separator
      str << body.to_s
      str.join("\n") + "\n"
    end
  end
end
