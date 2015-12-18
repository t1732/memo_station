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
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "タグ未設定なので作成できない" do
      expect {
        Article.create!(:title => hex, :body => hex, :tag_list => "")
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  it "削除できる" do
    assert article_create.destroy
  end

  it "タグ名の大文字小文字は区別せずuniqにする" do
    article = Article.create!(:title => hex, :body => hex, :tag_list => "foo FOO Foo")
    assert_equal ["foo"], article.tag_list
  end

  context "テキスト" do
    it "テキスト記事化" do
      assert article_create.to_text
    end

    describe "新規投稿" do
      before do
        @result = Article.text_post("
Title: title1
Tag: tag1
--text follows this line--
body1
")
        @article = Article.first
      end
      it do
        assert Article.exists?
        @result.should == "ポスト数: 1, 処理数: 1, skip: 0\nA  [1] title1"
      end

      describe "更新" do
        before do
          @result = Article.text_post("
Id: #{@article.id}
Title: title2
Tag: tag2
--text follows this line--
body2
")
          @article.reload
        end
        it do
          assert_equal "title2", @article.title
          assert_equal ["tag2"], @article.tag_list.sort
          assert_equal "body2", @article.body
          @result.should == "ポスト数: 1, 処理数: 1, skip: 0\nU  [1] title2"
        end
      end

      describe "ポストしたけど同じ内容なのでスキップ" do
        before do
          @result = Article.text_post(@article.to_text)
        end
        it do
          @result.should == "ポスト数: 1, 処理数: 0, skip: 1\n"
        end
      end
    end
  end
end
