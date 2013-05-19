# -*- coding: utf-8 -*-
module ApplicationHelper
  #
  # アイコン指定
  #
  #   bootstrap_icon()                    #=> nil
  #   bootstrap_icon("download")          #=> ' <i class="icon-download"></i> '
  #   bootstrap_icon("download", "white") #=> ' <i class="icon-download icon-white"></i> '
  #   bootstrap_icon("download white")    #=> ' <i class="icon-download icon-white"></i> '
  #
  def bootstrap_icon(*names)
    options = names.extract_options!
    klass = names.join(" ").gsub("_", "-").split(/\s+/).collect{|e|"icon-#{e}"}.join(" ")
    if klass.present?
      options[:class] = "#{options[:class]} #{klass}".strip
      (" " + content_tag(:i, "", options) + " ").html_safe
    end
  end
end
