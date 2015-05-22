# -*- coding: utf-8 -*-
require 'rails_helper'

RSpec.describe ArticlesController, type: :controller do
  before do
    Article.destroy_all
    @article = article_create
  end

  context "index" do
    it "index" do
      get :index
      assert_response :success
    end

    it "検索" do
      get :index, :query => @article.tag_list, :format => "txt"
      assert_response :success
      assert_match /#{@article.id}.*#{@article.title}.*#{@article.tag_list}.*#{@article.body}/m, response.body
    end
  end

  it "show" do
    get :show, :id => @article.id
    assert_response :success
  end

  it "new" do
    get :new
    assert_response :success
  end

  it "create" do
    post :create, :article => {:title => hex, :tag_list => hex, :body => hex}
    assert_response :redirect
  end

  it "edit" do
    get :edit, :id => @article.id
    assert_response :success
  end

  it "update" do
    put :update, :id => @article.id, :article => {:title => hex, :tag_list => hex, :body => hex}
    assert_response :redirect
  end

  it "destroy" do
    delete :destroy, :id => @article.id
    assert_response :redirect
  end

  it "test_post" do
    post :text_post, :content => "
Title: #{hex}
Tag: #{hex}
--text follows this line--
#{hex}
"
    assert_response :success
  end
end
