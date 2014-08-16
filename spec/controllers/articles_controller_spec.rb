# -*- coding: utf-8 -*-

require 'rails_helper'

RSpec.describe ArticlesController, :type => :controller do
  before do
    @article = FactoryGirl.create(:article, :tag_list => "t1")
  end

  it do
    get :index
    response.should be_success
  end

  it do
    get :show, :id => @article.id
    response.should be_success
  end

  it do
    get :new
    response.should be_success
  end

  it do
    post :create, :article => {:title => "(title)", :tag_list => "(tag_list)", :body => "(body)"}
    response.should be_redirect
  end

  it do
    get :edit, :id => @article.id
    response.should be_success
  end

  it do
    put :update, :id => @article.id, :article => {:title => "(title)", :tag_list => "(tag_list)", :body => "(body)"}
    response.should be_redirect
  end

  it do
    delete :destroy, :id => @article.id
    response.should be_redirect
  end

  it do
    get :index, :query => "t1", :format => "txt"
    response.should be_success
    response.body == <<-EOT
--------------------------------------------------------------------------------
Id: #{@article.id}
Title: #{@article.title}
Tag: t1
--text follows this line--
#{@article.body}
--------------------------------------------------------------------------------
EOT
  end

  it do
    post :text_post, :content => "
Title: タイトル
Tag: a b c
--text follows this line--
本文
"
    response.should be_success
  end
end
