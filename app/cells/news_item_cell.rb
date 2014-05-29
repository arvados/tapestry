class NewsItemCell < TapestryBaseCell

  def feed(options)
    show = (options && options[:show]) || [:blogs, :specimens]
    @news_items = []
    if show.index(:blogs)
      @news_items <<
        ExternalBlogPost.find(:all, :order => 'posted_at desc', :limit => (options[:limit] || 6))
    end
    if show.index(:specimens)
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
    @news_items.sort! { |a,b|
      ka = a.respond_to?(:news_feed_date) ? a.news_feed_date : a.created_at
      kb = b.respond_to?(:news_feed_date) ? b.news_feed_date : b.created_at
      ka <=> kb
    }
    @news_items.reverse!
    @news_items = @news_items[0, options[:limit]] if options[:limit]
    render
  end

end
