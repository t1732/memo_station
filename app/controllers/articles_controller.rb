# -*- coding: utf-8 -*-

class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy]

  def index
    if params.has_key?(:query)
      @articles = Article.tagged_with(params[:query]).limit(params[:limit] || 100)
    else
      @articles = Article.limit(params[:limit] || 100)
    end
    respond_to do |format|
      format.html
      format.xml { render :xml => @articles }
      format.txt { render_text_for_emacs(Article.separated_text_format(@articles)) }
    end
  end

  def text_post
    out = ""
    if Rails.env.development?
      out << [request.method, request.raw_post, request.query_string, params].inspect + "\n"
    end
    out << Article.text_post(params[:content])
    render_text_for_emacs(out)
  end

  def render_text_for_emacs(str)
    render :text => str
  end

  def show
  end

  def new
    @article = Article.new
  end

  def edit
  end

  def create
    @article = Article.new(article_params)

    respond_to do |format|
      if @article.save
        format.html { redirect_to @article, notice: 'Article was successfully created.' }
        format.json { render action: 'show', status: :created, location: @article }
      else
        format.html { render action: 'new' }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to @article, notice: 'Article was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @article.destroy
    respond_to do |format|
      format.html { redirect_to articles_url }
      format.json { head :no_content }
    end
  end

  private

  def set_article
    @article = Article.find(params[:id])
  end

  def article_params
    params.require(:article).permit(:title, :body, :tag_list)
  end
end
