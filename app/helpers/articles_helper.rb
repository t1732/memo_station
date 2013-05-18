# -*- coding: utf-8 -*-
module ArticlesHelper
  def html_title
    [AppConfig[:app_name], @page_title].compact.reverse.join(" - ")
  end

  def article_body(body)
    body = body.to_s
    body = html_escape(body)
    # body = body.gsub(/\n/, tag(:br))
    body = simple_format(body)
    body.html_safe
  end

  def article_tag_list(tag_list)
    # tag_list.collect{|e|link_to(e, polymorphic_path([:articles], :query => e), :class => "label notice")}.join(" ").html_safe
    tag_list.collect{|e|link_to(e, polymorphic_path([:articles], :query => e))}.join(" ").html_safe
  end
end
