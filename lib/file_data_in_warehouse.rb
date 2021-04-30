module FileDataInWarehouse

  def self.included(base)
    base.extend(ClassMethods)
  end

  def download_url
    # If KEEP_WEB_ROOT is defined and this user_file record has a PDH, use it to download the file
    if defined? KEEP_WEB_ROOT
      if self.locator
        if self.path_in_manifest
          return "#{KEEP_WEB_ROOT}/_/#{self.path_in_manifest}".gsub!(/https:\/\/%%LOCATOR%%/,"https:\/\/#{self.locator.gsub("+","-")}")
        elsif self.dataset_file_name
          # For historical reasons (a Keep limitation from many years ago, no
          # longer the case), longupload (the code at
          # https://github.com/arvados/longupload/blob/master/stores_in_warehouse.rb#L62)
          # replaces spaces with underscores in the manifest, but not in the
          # dataset_file_name field in the datase. Cf.
          # https://dev.arvados.org/issues/1278
          #
          # Make the same change here so we generate the right url.
          return "#{KEEP_WEB_ROOT}/_/#{self.dataset_file_name.gsub!(/ /,'_')}".gsub!(/https:\/\/%%LOCATOR%%/,"https:\/\/#{self.locator.gsub("+","-")}")
        end
      end
    end
    if defined? WAREHOUSE_WEB_ROOT and
        defined? WAREHOUSE_FS_ROOT
      if self.path_in_manifest
        return "#{WAREHOUSE_WEB_ROOT}/#{self.locator}/#{self.path_in_manifest}"
      end
      if (filelist = Dir.glob("#{WAREHOUSE_FS_ROOT}/#{self.locator}/*")) and
          filelist.size == 1
        return filelist[0].sub(WAREHOUSE_FS_ROOT, WAREHOUSE_WEB_ROOT)
      end
    end
    if defined? WAREHOUSE_PROXY_SCRIPT_PATH
      return WAREHOUSE_PROXY_SCRIPT_PATH +
        '?locator=' + Rack::Utils.escape(self.locator + '/') +
        '&filename=' + Rack::Utils.escape(filename) +
        '&size=' + @user_file.data_size.to_s +
        '&type=' + Rack::Utils.escape(self.dataset_content_type) +
        '&disposition=attachment'
    end
  end

  module ClassMethods
    def multiple_new_from_manifest(*create_args)
      manifest_text = create_args.last[:manifest_text]
      flist = []
      fileindex = -1
      manifest_text.split("\n").each do |stream|
        tokens = stream.split(" ")
        stream_name = tokens.shift
        stream_prefix = (stream_name == '.' ? '' : stream_name + '/')
        tokens.each do |token|
          fileinfo = token.match(/^(\d+):(\d+):(.*)/) || next
          fileindex += 1
          new_args = create_args.clone
          new_args.last.merge!({
            :file_size => fileinfo[2].to_i,
            :file_name => fileinfo[3],
            :index_in_manifest => fileindex,
            :path_in_manifest => stream_prefix + fileinfo[3]
          })
          flist << new(*new_args)
        end
      end
      flist
    end
  end
end
