# -*- coding: utf-8 -*-
require "spec_helper"

describe Article do
  before do
    @article = Article.new
  end

  describe "作成" do
    it "できる" do
      @article.update_attributes(:title => "title", :body => "body", :tag_list => "a b c")
      @article.should be_valid
    end

    it "できない(タグが設定されてないので)" do
      @article.update_attributes(:title => "title", :body => "body", :tag_list => "")
      @article.should be_invalid
    end

    it "スペースを含むタグは囲むとコンテキスト扱い" do
      @article.update_attributes(:title => "title", :body => "body", :tag_list => "'a b' c")
      @article.should be_valid
      @article.tag_list.should == ["a b", "c"]
    end
  end

  describe "更新" do
    before do
      @article = FactoryGirl.create(:article)
    end

    describe "できる" do
      it "普通に" do
        @article.update_attributes(:tag_list => "a b c")
        @article.should be_valid
      end

      it "タイトルだけを更新" do
        @article.update_attributes(:title => "title2")
        @article.should be_valid
      end

      it "本文を空で更新" do
        @article.update_attributes(:body => "")
        @article.should be_valid
      end
    end

    describe "できない" do
      it "タグが空なので" do
        @article.update_attributes(:tag_list => "")
        @article.should be_invalid
      end

      it "タイトルが空なので" do
        @article.update_attributes(:title => "")
        @article.should be_invalid
      end
    end
  end

  describe "削除" do
    before do
      @article = FactoryGirl.create(:article)
    end

    it "できる" do
      proc { @article.destroy }.should change(Article, :count).by(-1)
    end
  end
end
