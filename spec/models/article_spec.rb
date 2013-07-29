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

    it "できない(タグ未設定)" do
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

      it "タイトルのみ" do
        @article.update_attributes(:title => "title2")
        @article.should be_valid
      end

      it "本文を空で" do
        @article.update_attributes(:body => "")
        @article.should be_valid
      end
    end

    describe "できない" do
      it "タグ未入力" do
        @article.update_attributes(:tag_list => "")
        @article.should be_invalid
      end

      it "タイトル未入力" do
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

  describe "Emacsインタフェース" do
    before do
      Article.text_post("
Title: タイトル
Tag: b a
--text follows this line--
本文
")
      @article = Article.first
    end

    it "作成できる" do
      @article.title.should == "タイトル"
      @article.body.should == "本文"
      @article.tag_list.should == ["b", "a"]
    end

    it "更新できる" do
      Article.text_post("
Id: #{@article.id}
Title: タイトル
Tag: a b c
--text follows this line--
本文2
")
      @article.reload
      @article.tag_list.should == ["b", "a", "c"]
    end

    it "参照できる" do
      @article.to_text.should == <<-EOT.strip_heredoc
Id: #{@article.id}
Title: タイトル
Tag: b a
Date: 2000-01-01 00:00
--text follows this line--
本文
EOT
    end
  end
end
