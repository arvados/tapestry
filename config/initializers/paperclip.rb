Paperclip.interpolates :user_id do |attachment, style| 
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

Paperclip.interpolates :filename do |attachment, style| 
  hex = User.find(attachment.instance.user_id).hex
  hex + '_' + attachment.instance.created_at.strftime("%Y%m%d%H%M%S")
end

Paperclip.interpolates :study_id do |attachment, style| 
  attachment.instance.study.id
end

Paperclip.interpolates :instructions_filename do |attachment, style| 
  attachment.instance.instructions_file_name
end
