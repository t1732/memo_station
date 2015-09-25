module ArticlesHelper
  def html_title
    [AppConfig[:app_name], @page_title].compact.reverse.join(" - ")
  end

  def article_body(body)
    body = body.to_s
    body = html_escape(body)
    body = simple_format(body)
    body = auto_link(body)
    body.html_safe
  end

  def article_tag_list(tag_list)
    tag_list.collect {|e|link_to(e, polymorphic_path([:articles], :query => e))}.join(" ").html_safe
  end
end
