# -*- coding: utf-8 -*-
require "pp"

desc "開発環境セットアップ"
task :setup => ["log:clear", "tmp:clear", "db:migrate:reset", "db:seed", "db:structure:dump", "test"]

task :import => :environment do
  Article.destroy_all
  
  # only や except は必ず ["users"] の形式でなければダメ
  DatabaseCleaner.clean_with(:truncation) # 一回だけ実行する場合
  # DatabaseCleaner.strategy = :truncation # {:only => ["items"]} or {:except => ["articles"]}
  # DatabaseCleaner.start
  # DatabaseCleaner.clean

  records = Marshal.load(Pathname("~/memo_station.db").expand_path.read)
  p records.size
  records.each{|record|
    # if record["id"] == 2272
    #   pp record
    #   puts "--------------------------------------------------------------------------------"
    #   puts record["body"]
    #   puts "--------------------------------------------------------------------------------"
    #   exit
    # end

    if record["id"] >= 0
      # p [:read, record["id"]]

      tags = record.delete(:tags)

      ["tag_list", "subject", "tag_list"].each{|key|
        begin
          record[key] = record[key].force_encoding("UTF-8")
        rescue => error
          p key
          p record
          p error
          raise error
        end
      }

      record["tag_list"].gsub!("┗(^o^)┓三", "")
      record["tag_list"] = record["tag_list"].gsub(/[%{}$<>\(\)~\\#'"^\|]/, " ").squish

      body = record["body"].to_s.strip
      url = record["url"]
      if url.present?
        body = "#{url}\n\n#{body}".strip
      end
      if body.present?
        article = Article.new({
            :title => record["subject"].force_encoding("utf-8"),
            :body => body.force_encoding("utf-8"),
            :tag_list => record["tag_list"].force_encoding("utf-8"),
            :created_at => record["created_at"],
            :updated_at => record["updated_at"],
          })

        if article.invalid?
          p [:skip, article.errors]
          next
        end

        require "timeout"
        begin
          Timeout::timeout(20) do
            article.save!
          end
        rescue ActiveRecord::RecordInvalid => error
          p error
          pp article.errors
          pp article.attributes
          raise error
        rescue Timeout::Error => error
          pp error
          pp record
          pp article.attributes
          raise error
        rescue => error
          pp error
          pp record
          pp article.attributes
          raise error
        end
        # p article.id
        # p [:write, article.id, record["subject"]]
      else
        p [:skip, record["subject"]]
      end
    end
  }
end
