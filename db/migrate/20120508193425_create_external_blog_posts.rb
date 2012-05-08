class CreateExternalBlogPosts < ActiveRecord::Migration
  def self.up
    create_table :external_blog_posts do |t|
      t.string :feed_url
      t.timestamp :retrieved_at
      t.timestamp :posted_at
      t.string :post_url
      t.text :title
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :external_blog_posts
  end
end
