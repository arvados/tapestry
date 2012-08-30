module SubmitToGetEvidence

  def submit_to_get_evidence!(options = {})
    submit_params = {
      'api_key' => GET_EVIDENCE_API_KEY,
      'api_secret' => GET_EVIDENCE_API_SECRET,
      'dataset_locator' => self.locator,
      'dataset_name' => options[:name] || self.name,
      'dataset_is_public' => options[:make_public] ? '1' : '0',
      'human_id' => options[:human_id] || self.human_id
    }
    [:controlled_by].each { |x|
      submit_params[x.to_s] = options[x] if options.has_key? x
    }
    query_string = submit_params.collect {
      |k,v| URI.encode(k, /\W/) + '=' + URI.encode(v.to_s, /\W/)
    }.join('&')
    json_object = JSON.parse(open("#{GET_EVIDENCE_BASE_URL}/submit?#{query_string}").read)
    unless json_object['success']
      raise "GET-Evidence submit error: #{json_object['error']}"
    end
    self.download_url = json_object['download_url'] if self.respond_to? :download_url
    self.status_url = json_object['status_url']
    self.processing_stopped = false
    self.save!
    logger.debug self.inspect
  end

  def update_processing_status!
    self.processing_status = JSON.parse(open(self.status_url).read,
                                        :symbolize_names => true)[:status]
    self.processing_status[:updated_at] = Time.now
    if ['finished','failed'].index(self.processing_status[:status])
      self.processing_stopped = true
      if processing_status[:status] == 'finished'
        self.report_url = processing_status[:result_url]
        fetch_report_metadata
      end
    else
      self.processing_stopped = false
    end
    self.save!
  end

  def fetch_report_metadata
    if self.report_url
      report_json_url = self.report_url
      if report_json_url.index('?')
        report_json_url += '&format=json'
      else
        report_json_url += '?format=json'
      end
      report_data = JSON.parse(open(report_json_url).read,
                               :symbolize_names => true)
      self.report_metadata = report_data[:metadata] rescue nil
    end
  end

  def report_ready?
    !!report_url
  end

end
