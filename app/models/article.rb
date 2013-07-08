# -*- coding: utf-8 -*-

class Article < ActiveRecord::Base
  include Emacsen
  acts_as_taggable

  default_scope { order(arel_table[:updated_at].desc) }

  before_validation do
    if changes.has_key?(:title)
      self.title = title.to_s.squish.presence
    end
    if changes.has_key?(:body)
      self.body = body.to_s.strip.presence
    end
    true
  end

  with_options(:presence => true) do |o|
    o.validates :tag_list
    o.validates :title
  end

  with_options(:allow_blank => true) do |o|
    o.validates :title, :uniqueness => true
  end
end
