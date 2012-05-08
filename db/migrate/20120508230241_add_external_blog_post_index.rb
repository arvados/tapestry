class AddExternalBlogPostIndex < ActiveRecord::Migration
  def self.up
    add_index :external_blog_posts, [:feed_url, :post_url], :unique => true
  end

  def self.down
    remove_index :external_blog_posts, [:feed_url, :post_url]
  end
end
