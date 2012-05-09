class NewsItemCell < Cell::Rails

  def feed(options)
    @news_items =
      ExternalBlogPost.find(:all, :order => 'posted_at desc', :limit => 6)
    if options and options[:user]
      @news_items << SampleLog.
        includes(:sample).
        where('samples.participant_id = ?', options[:user].id).
        order('sample_logs.created_at desc').
        limit(20)
      @news_items << KitLog.
        includes(:kit).
        where('kits.participant_id = ?', options[:user].id).
        order('kit_logs.created_at desc').
        limit(20)
    end
    @news_items.flatten!
    @news_items.reject! { |x|
      (!x.respond_to?(:news_feed_summary) &&
       !x.respond_to?(:news_feed_raw_summary)) ||
      !x.respond_to?(:news_feed_title) ||
      !x.respond_to?(:created_at)
    }
    @news_items.sort! { |a,b| a.created_at <=> b.created_at }
    @news_items.reverse!
    render
  end

end
