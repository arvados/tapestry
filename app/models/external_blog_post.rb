class ExternalBlogPost < ActiveRecord::Base
  validates_uniqueness_of :post_url, :scope => :feed_url
end
