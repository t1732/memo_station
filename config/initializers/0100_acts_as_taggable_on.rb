module ActsAsTaggableOn
  class WhiteSpaceSplitParser < GenericParser
    def parse
      ActsAsTaggableOn::TagList.new.tap do |tag_list|
        tag_list.add @tag_list.split(/\s+/)
      end
    end
  end
end

ActsAsTaggableOn.setup do |config|
  config.default_parser = ActsAsTaggableOn::WhiteSpaceSplitParser
  config.remove_unused_tags = true
end
