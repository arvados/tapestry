at_9am = Time.parse('2012-04-25 09:00:00')
at_5pm = Time.parse('2012-04-25 17:00:00')
at_630pm = Time.parse('2012-04-25 18:30:00')
mad = User.find(5555)
tom = User.find(5487)

claimus=CSV.read('/home/tomc/GET2012 blood kit claim transcribed from paper list - Sheet1.csv')
claimus.
  each do |row|
  appttime, fullname, kitname, kitid, huid, lastreceived = row
  next if kitname.nil? or kitname.empty?
  kit = Kit.find_by_name(kitname)
  next if !kit or !kit.last_mailed or kit.last_received
  row[7] = kit.samples.collect(&:url_code).join(' ')
  row[3] = kit.id

  if huid and !huid.empty?
    user = User.where('hex = ?', huid).first
  else
    hunames = fullname.split ' '
    user = User.where('first_name = ? and last_name = ?', hunames[0], hunames.last)
    if user.size == 1 and user.first.hex
      user = user.first
      row[4] = user.hex
    else
      next
    end
  end

  kit.last_received = at_9am
  kit.last_mailed = at_5pm
  kit.participant = user
  kit.owner = mad
  kit.save
  kit.samples.each do |s|
    s.participant = user
    s.last_received = at_9am
    s.last_mailed = at_5pm
    s.owner = nil
    SampleLog.new(:actor => user, :comment => 'Sample received by participant',
                  :sample_id => s.id,
                  :created_at => at_9am, :updated_at => at_9am).save
    SampleLog.new(:actor => user, :comment => 'Sample returned to researcher',
                  :sample_id => s.id,
                  :created_at => at_5pm, :updated_at => at_5pm).save
    if s.name.match(/ACD/)
      s.owner = mad
      SampleLog.new(:actor => mad, :comment => 'Sample received by researcher',
                    :sample_id => s.id,
                    :created_at => at_5pm, :updated_at => at_5pm).save
      SampleLog.new(:actor => tom, :comment => 'Sample shipped to Coriell',
                    :sample_id => s.id,
                    :created_at => at_630pm, :updated_at => at_630pm).save
    end
    s.save
  end
  KitLog.new(:actor => user, :comment => 'Kit received by participant',
             :kit_id => kit.id,
             :created_at => at_9am, :updated_at => at_9am).save
  KitLog.new(:actor => user, :comment => 'Kit returned to researcher',
             :kit_id => kit.id,
             :created_at => at_5pm, :updated_at => at_5pm).save
  KitLog.new(:actor => mad, :comment => 'Kit received by researcher',
             :kit_id => kit.id,
             :created_at => at_5pm, :updated_at => at_5pm).save

  kit.reload
  row[6] = kit.kit_logs.last.comment
end

CSV.open('/tmp/claimed.csv','wb') do |csv|
 claimus.each { |c| csv << c }
end
