# -*- coding: utf-8 -*-
require 'rails_helper'

RSpec.describe Article, type: :model do
  before do
    Article.destroy_all
  end

  context "作成できる" do
    it "作成できる" do
      assert_nothing_raised do
        article_create
      end
    end
    it "タイトルのみで作成できる" do
      assert_nothing_raised do
        Article.create!(:title => hex, :tag_list => hex)
      end
    end
  end

  context "作成できない" do
    it "タイトル未入力なので作成できない" do
      expect {
        Article.create!(:title => "", :body => hex, :tag_list => hex)
      }.to raise_error
    end

    it "タグ未設定なので作成できない" do
      expect {
        Article.create!(:title => hex, :body => hex, :tag_list => "")
      }.to raise_error
    end
  end

  it "削除できる" do
    assert article_create.destroy
  end

  it "タグ名の大文字小文字は区別せずuniqにする" do
    r = Article.create!(:title => hex, :body => hex, :tag_list => "foo FOO Foo")
    assert_equal ["foo"], Article.find(r.id).tag_list
  end

  context "テキスト" do
    it "テキストで参照できる" do
      assert article_create.to_text
    end

    it "テキストから作成できる" do
      result = Article.text_post("
Title: #{hex}
Tag: #{hex}
--text follows this line--
#{hex}
")
      assert Article.exists?
      assert result
    end

    it "テキストから更新できる" do
      article = article_create
      Article.text_post("
Id: #{article.id}
Title: (changed_title)
Tag: (changed_tag)
--text follows this line--
(changed_body)
")
      article.reload
      assert_equal "(changed_title)", article.title
      assert_equal ["(changed_tag)"], article.tag_list.sort
      assert_equal "(changed_body)", article.body
    end
  end
end
