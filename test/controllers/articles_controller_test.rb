# -*- coding: utf-8 -*-
require 'test_helper'

class ArticlesControllerTest < ActionController::TestCase
  setup do
    Article.destroy_all
    @article = article_create
  end

  test "index" do
    get :index
    assert_response :success
  end

  test "show" do
    get :show, :id => @article.id
    assert_response :success
  end

  test "new" do
    get :new
    assert_response :success
  end

  test "create" do
    post :create, :article => {:title => hex, :tag_list => hex, :body => hex}
    assert_response :redirect
  end

  test "edit" do
    get :edit, :id => @article.id
    assert_response :success
  end

  test "update" do
    put :update, :id => @article.id, :article => {:title => hex, :tag_list => hex, :body => hex}
    assert_response :redirect
  end

  test "destroy" do
    delete :destroy, :id => @article.id
    assert_response :redirect
  end

  test "検索" do
    get :index, :query => @article.tag_list, :format => "txt"
    assert_response :success
    assert_match /#{@article.id}.*#{@article.title}.*#{@article.tag_list}.*#{@article.body}/m, response.body
  end

  test "test_post" do
    post :text_post, :content => "
Title: #{hex}
Tag: #{hex}
--text follows this line--
#{hex}
"
    assert_response :success
  end
end
