class ApplicationController < ActionController::Base
  before_action :set_locale

  private

  def change_locale
    session[:locale] = params[:locale] if params[:locale].present?
    redirect_back(fallback_location: root_path)
  end

  def set_locale
    I18n.locale = session[:locale] || I18n.default_locale
  end
end
