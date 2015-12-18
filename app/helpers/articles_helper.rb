module ArticlesHelper
  def html_title
    [AppConfig[:app_name], @page_title].compact.reverse.join(" - ")
  end

  def article_body(body)
    s = body.to_s
    s = html_escape(s)
    s = auto_link(s)
    s.html_safe
  end

  def article_tag_list(tag_list)
    tag_list.collect { |e|
      link_to(e, [:articles, :query => e])
    }.join(" ").html_safe
  end
end
