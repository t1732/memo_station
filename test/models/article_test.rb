# -*- coding: utf-8 -*-
require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  setup do
    Article.destroy_all
  end

  sub_test_case "作成できる" do
    test "作成できる" do
      assert_nothing_raised do
        article_create
      end
    end
    test "タイトルのみで作成できる" do
      assert_nothing_raised do
        Article.create!(:title => hex, :tag_list => hex)
      end
    end
  end

  sub_test_case "作成できない" do
    test "タイトル未入力なので作成できない" do
      assert_raise do
        Article.create!(:title => "", :body => hex, :tag_list => hex)
      end
    end

    test "タグ未設定なので作成できない" do
      assert_raise do
        Article.create!(:title => hex, :body => hex, :tag_list => "")
      end
    end
  end

  test "削除できる" do
    assert article_create.destroy
  end

  test "タグ名の大文字小文字は区別せずuniqにする" do
    r = Article.create!(:title => hex, :body => hex, :tag_list => "foo FOO Foo")
    assert_equal ["foo"], Article.find(r.id).tag_list
  end

  sub_test_case "テキスト" do
    test "テキストで参照できる" do
      assert article_create.to_text
    end

    test "テキストから作成できる" do
      result = Article.text_post("
Title: #{hex}
Tag: #{hex}
--text follows this line--
#{hex}
")
      assert Article.exists?
      assert result
    end

    test "テキストから更新できる" do
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

  private

  def hex
    SecureRandom.hex
  end

  def article_create
    Article.create!(:title => hex, :body => hex, :tag_list => hex)
  end
end
