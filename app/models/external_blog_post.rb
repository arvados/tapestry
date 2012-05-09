class ExternalBlogPost < ActiveRecord::Base
  validates_uniqueness_of :post_url, :scope => :feed_url

  def news_feed_title
    self.title
  end
  def news_feed_raw_summary
    self.description
  end
  def news_feed_link_to
    self.post_url
  end
end
