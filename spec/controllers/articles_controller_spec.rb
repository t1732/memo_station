# -*- coding: utf-8 -*-

require "spec_helper"

describe ArticlesController do
  # context do
  #   it do
  #     get :index
  #     response.should be_success
  #   end
  # end

  context "Emacs対応" do
    it "書き込みできる" do
      post :text_post, :content => "
Title: タイトル
Tag: a b c
--text follows this line--
本文
"
      response.should be_success
    end

    it "読み出せる" do
      article = FactoryGirl.create(:article, :tag_list => "t1")
      get :index, :query => "t1", :format => "txt"
      response.should be_success
      assigns(:articles).should == [article]
      response.body == <<-EOT
--------------------------------------------------------------------------------
Id: #{article.id}
Title: #{article.title}
Tag: t1
--text follows this line--
#{article.body}
--------------------------------------------------------------------------------
EOT
    end
  end
end
