# -*- coding: utf-8 -*-
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'test/unit/rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  private

  def hex
    SecureRandom.hex
  end

  def article_create
    Article.create!(:title => hex, :body => hex, :tag_list => hex)
  end
end
