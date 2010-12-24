Paperclip::Attachment.interpolations[:user_id] = proc do |attachment, style|
  id = attachment.instance.user_id.to_s
  if id.length % 2 == 1
    id = '0' + id
  end
  f = ''
  while not id.nil? and id.length > 0
    f = f + id[0,2] + '/'
    id = id[2, id.length]
  end
  f.gsub!(/\/$/,'')
end
