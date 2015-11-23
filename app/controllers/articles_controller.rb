class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy]

  if Rails.env.development?
    before_action do
      logger.debug [request.method, request.raw_post, request.query_string, params]
    end
  end

  def index
    @articles = Article.limit(params[:limit] || 100)
    if params.has_key?(:query)
      @articles = @articles.tagged_with(params[:query])
    end
    respond_to do |format|
      format.html
      format.json { render :json => @articles.to_json(:methods => :tag_list) }
      format.xml  { render :xml => @articles.to_xml(:methods => :tag_list, :dasherize => false) }
      format.txt  { render :text => Article.separated_text_format(@articles) }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render :json => @article.to_json(:methods => :tag_list) }
      format.xml  { render :xml => @article.to_xml(:methods => :tag_list, :dasherize => false) }
      format.txt  { render :text => Article.separated_text_format([@article]) }
    end
  end

  def new
    @article = Article.new
  end

  def edit
  end

  def text_post
    render :text => Article.text_post(params[:content])
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
      format.html { redirect_to :articles }
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
