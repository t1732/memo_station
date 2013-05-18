# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.

require_dependency "login_system"

class ApplicationController < ActionController::Base
  session :session_key => '_memo_station_session_id'

  # コントローラ内で simple_format を使おうとしたら content_tag がないと言われたので対処
  include ActionView::Helpers::TagHelper
  # include ActionView::Helpers::TextHelper

  # クラスのインスタンス変数 @global_navi_category に必要であれば所属カテゴリをセットする
  class << self
    attr_accessor :global_navi_category
    def set_global_navi_category(global_navi_category)
      @global_navi_category = global_navi_category.to_s
    end
  end

  # 自分のカテゴリ名を取得
  # デフォルトで
  def my_category
    self.class.global_navi_category || self.controller_name
  end

  include LoginSystem
  model :user

  # セッションの生存期間をユーザーが最後に訪れたときから固定の期間する方法
  before_filter :update_session
  def update_session
    logger.debug("before_filter: update_session")

    logger.debug("セッション #{session ? "有効" : "無効"}")
    if session[:user]

      # user関連のDBの更新を反映させる。
      session[:user].reload

      ::ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.update(:session_expires => 1.years.from_now)
      logger.debug("#{session[:user].loginname} のセッション生存期間を #{::ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS[:session_expires]} に更新しました in update_session()")
    else
      logger.debug("session[:user] は設定されていません in update_session()")
    end
    return true
  end


  # 公開して開発者以外がアクセスしたときのエラー処理。
  # ActionController::Base.consider_all_requests_local が false で、

  # local_request? が false のときに rescue_action_in_public は呼ばれる。

  # エラー発生時にメール送る
  def rescue_action_in_public(exception)
    case exception
    when ActiveRecord::RecordNotFound, ::ActionController::UnknownAction
      render(:text => IO.read(File.join(RAILS_ROOT, 'public', '404.html')), :status => "404 Not Found")
    else
      render(:file => "#{RAILS_ROOT}/public/500.html", :status => "500 Error")
    end
    Mailman.deliver_exception_notification(self, request, exception)
  end

  # 開発者の環境からアクセスされているか調べる。
  # ここにマッチする場合、rescue_action_locally が呼ばれる。
  # マッチしなければ rescue_action_in_public が呼ばれる。
  def local_request? #:doc:
    ["127.0.0.1", "192.168.11.6"].include?(request.remote_ip)
  end
end
