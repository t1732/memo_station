# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :article do
    sequence(:title){|i|"(title#{i})" }
    sequence(:body){|i|"(body#{i})" }
    tag_list "t1 t2"
  end
end
