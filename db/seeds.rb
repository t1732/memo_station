# -*- coding: utf-8 -*-

if Rails.env.development?
  body = ""
  body << "ああああああああ\n"
  body << "ああああああああ\n"
  body << "\n"
  body << "ああああああああ\n"
  body << "ああああああああ\n"
  body << "http://www.google.co.jp/\n"
  body << "<hr>\n"
  3.times {p Article.create!(:title => "title#{Article.count}", :body => body, :tag_list => "a b c")}
end
