
require 'rubygems'
require 'net/http'
require 'uri'
require 'cgi'
require 'thread'
require 'find'
require 'yaml'

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'
include PhrccrsHelper
include Admin::UsersHelper

# Flush STDOUT/STDERR immediately
STDOUT.sync = true
STDERR.sync = true

class WorkObject
	attr_accessor :action
	attr_accessor :user_id
	attr_accessor :report_id
	attr_accessor :report_name
	attr_accessor :report_type
	attr_accessor :authsub_token
	attr_accessor :etag
	attr_accessor :ccr_profile_url
	attr_accessor :ccr_contents
	attr_accessor :user_file_id
	attr_accessor :filter
end

class MyPG

	attr_reader :data_path
	attr_reader :config

	def initialize(data_path)
		@data_path = data_path

		@config = read_config()

		mode = ENV['RAILS_ENV']

		if @config.has_key?(mode) then
			@config = @config[mode]
		else
			puts "Mode #{mode} not found in Config file - aborting."
	    exit 1
		end

    # These keys are required in the config file
    @required_keys = ['callback_port','callback_host','workers']
    exit 1 if not required_keys_exist(@required_keys)

		@queue = Queue.new
		@consumers = (1..@config['workers']).map do |i|
		  Thread.new("consumer #{i}") do |name|
		    begin
		      work = @queue.deq
          begin
			      print "#{name}: started work for user #{work.user_id}: #{work.action}\n"
						if work.action == 'get_ccr' then
							get_ccr_worker(work)
						elsif work.action == 'process_ccr' then
							process_ccr_worker(work)
						elsif work.action == 'report' then
							report_worker(work)
						elsif work.action == 'process_file' then
							process_file_worker(work)
						end
			      print "#{name}: finished work for user #{work.user_id}: #{work.action}\n"
			      sleep(rand(0.1))
					rescue Exception => e
            if e.to_s =~ /has gone away/ or e.to_s =~ /Lost connection/ then
              puts "MySQL went away; re-establishing connection and retrying."
              ActiveRecord::Base.establish_connection and retry
              retry
            end
						puts "Trapped exception in worker: #{e.to_s}"
            puts "#{work.action}: job failed: #{e.inspect()}"
            puts "#{e.backtrace()}"
    				callback('userlog',work.user_id,
              { "message" => "#{work.action}: job failed: #{e.inspect()}", 
                "user_message" => "Error: job failed." } )
					end
		    end until work == :END_OF_WORK
		  end
		end
	end

  def required_keys_exist(required)
    all_found = true
    required.each do |r|
  		if not @config.has_key?(r) then
 			  puts "Error: required key '#{r}' not found for mode #{ENV['RAILS_ENV']} in config file."
        all_found = false
  		end
    end
    return all_found
  end

  def read_config
    file = File.dirname(__FILE__) + '/MyPG.yml'
    @config = Hash.new()
    if not FileTest.file?(file)
      puts "Config file #{file} not found - aborting."
			exit 1
    else
      @config = YAML::load_file(file)
			if (@config == false) then
				puts "Config file #{file} corrupted or empty - aborting."
	      exit 1
			end
    end 
    return @config
  end

  def create_international_users_scoreboard_worker(work)
    user_table = Hash.new()

    InternationalParticipant.select("count(international_participants.id) AS count, country").group("country").each do |r|
      user_table[r.country] = Hash.new() if not user_table.has_key?(r.country)
      user_table[r.country]['count'] = r.count.to_i
    end
    buf = ''
    header_row = ['Country','Count']

    CSV.generate_row(header_row, header_row.size, buf)

    user_table.sort { |a,b| b[1]['count'] <=> a[1]['count'] }.each do |month,data|
      row = []
      row.push month
      row.push data['count']
      CSV.generate_row(row, row.size, buf)
    end
    csv_filename = generate_csv_filename('international_users_scoreboard', true)
    outFile = File.new(csv_filename, 'w')
    outFile.write(buf)
    outFile.close
    return csv_filename
  end

  def create_user_log_report_worker(work)
    filter = '%'
    filter = '%' + work.filter + '%' if work.filter
    counter = 0

    @users = Hash.new()

    # Build a @users hash to look up the appropriate user label (below).
    # This is much faster than letting AR do the job for each UserLog record.
    # There are orders of magnitude more UserLog records than User records, so
    # in terms of memory vs speed, this is a pretty good tradeoff.
    puts "#{Time.now().to_s} Start making @users hash"
    User.find_each do |u|
      if u.hex == '' then
        @users[u.id] = u.unique_hash
      else
        @users[u.id] = u.hex
      end
    end
    puts "#{Time.now().to_s} Done making @users hash"

    report = StringIO.new

    header = ['When','Who','Log entry']

    # Ideally we'd have something like
    #    order('user_logs.created_at desc')
    # in the UserLog AR call, but find_each doesn't support sorting.
    # The use of find_each is absolutely essential to keep memory use more
    # reasonable. Using 'each' leads to completely unreasonable memory use.
    #
    # I also experimented with larger batch sizes (5000, 10000 - default is 1000)
    # but they don't make this export measurably faster. They do increase memory
    # usage, so I decided to stick to the default.
    CSV::Writer.generate(report) do |csv|
      csv << header

      if filter == '%' then
        UserLog.find_each { |r|
          csv << [ r.created_at, @users.has_key?(r.user_id) ? @users[r.user_id] : '', r.comment ]
          puts "#{Time.now().to_s} UserLog counter: #{counter.to_s}" if ((counter % 1000) == 0)
          counter += 1
        }
      else
        UserLog.where('comment like ? or users.hex like ?', filter, filter) { |r|
          csv << [ r.created_at, @users.has_key?(r.user_id) ? @users[r.user_id] : '', r.comment ]
          puts "#{Time.now().to_s} UserLog counter: #{counter.to_s}" if ((counter % 1000) == 0)
          counter += 1
        }
      end
    end
    puts "#{Time.now().to_s} UserLog counter: csv generation complete, about to write it to disk"
    report.rewind

    csv_filename = generate_csv_filename('user_log', true)
    outFile = File.new(csv_filename, 'w')
    outFile.write(report.read)
    outFile.close
    return csv_filename
  end

  def create_international_users_list_worker(work)
    user_table = Hash.new()

    InternationalParticipant.all.each do |r|
      user_table[r.email] = Hash.new() if not user_table.has_key?(r.email)
      user_table[r.email]['country'] = r.country
    end
    buf = ''
    header_row = ['E-mail','Country']

    CSV.generate_row(header_row, header_row.size, buf)

    user_table.sort { |a,b| a[1]['country'] <=> b[1]['country'] }.each do |month,data|
      row = []
      row.push month
      row.push data['country']
      CSV.generate_row(row, row.size, buf)
    end
    csv_filename = generate_csv_filename('international_users_list', true)
    outFile = File.new(csv_filename, 'w')
    outFile.write(buf)
    outFile.close
    return csv_filename
  end

  def create_enrollment_report_worker(work)
    users = User.real

    user_table = Hash.new()

    User.has_completed('signup').select('count(users.id) as count,YEAR(enrollment_step_completions.created_at) as year,MONTH(enrollment_step_completions.created_at) as month').group("YEAR(enrollment_step_completions.created_at), MONTH(enrollment_step_completions.created_at)").each do |r|
      month = "#{r.year}-#{sprintf("%02d",r.month)}"
      user_table[month] = Hash.new() if not user_table.has_key?(month)
      user_table[month]['signup'] = r.count
    end

    User.enrolled.select('count(id) as count,YEAR(enrolled) as year,MONTH(enrolled) as month').group("YEAR(enrolled), MONTH(enrolled)").each do |r|
      month = "#{r.year}-#{sprintf("%02d",r.month)}"
      user_table[month] = Hash.new() if not user_table.has_key?(month)
      user_table[month]['enrolled'] = r.count
    end

    User.deactivated.where('can_reactivate_self = ?',false).select('count(id) as count,YEAR(deactivated_at) as year,MONTH(deactivated_at) as month').group("YEAR(deactivated_at), MONTH(deactivated_at)").each do |r|
      month = "#{r.year}-#{sprintf("%02d",r.month)}"
      user_table[month] = Hash.new() if not user_table.has_key?(month)
      user_table[month]['withdrawn'] = r.count
    end

    buf = ''
    header_row = ['Month','Signed up','Enrolled','Withdrawn']

    CSV.generate_row(header_row, header_row.size, buf)

    user_table.sort.reverse.each do |month,data|
      row = []
      row.push month
      if data.has_key?('signup') then
        row.push data['signup']
      else
        row.push 0
      end
      if data.has_key?('enrolled') then
        row.push data['enrolled']
      else
        row.push 0
      end
      if data.has_key?('withdrawn') then
        row.push data['withdrawn']
      else
        row.push 0
      end
      CSV.generate_row(row, row.size, buf)
    end
    csv_filename = generate_csv_filename('enrollment_report', true)
    outFile = File.new(csv_filename, 'w')
    outFile.write(buf)
    outFile.close
    return csv_filename
  end

  def create_exam_report_worker(work)
    users = User.real

    buf = ''
    header_row = ['Hash','Exam response id','Question','Answer','Correct','Date/time']

    CSV.generate_row(header_row, header_row.size, buf)
    users.each do |user|
      ExamResponse.all_for_user(user).each do |er|
        er.question_responses.each do |qr|
          row = []
          row.push user.unique_hash
          row.push qr.exam_response_id
          row.push qr.exam_question_id
          row.push qr.answer
          row.push qr.correct
          row.push qr.created_at
          CSV.generate_row(row, row.size, buf)
        end
      end
    end
    csv_filename = generate_csv_filename('exam_report', true)
    outFile = File.new(csv_filename, 'w')
    outFile.write(buf)
    outFile.close
    return csv_filename
  end

  def create_absolute_pitch_survey_question_key_report_worker(work)
    aps = Survey.find_by_name("Absolute Pitch Survey")
    survey_users = User.find(:all, :conditions => 'absolute_pitch_survey_completion IS NOT NULL AND NOT is_test = true', :order => 'hex')
    questions = []
    if not aps.nil? then
      aps.survey_sections.each {|s|
        questions << s.survey_questions
      }
    end
    questions = questions.flatten.sort{|x,y| x.id <=> y.id }.select{|q| q.question_type != 'end'}

    report = StringIO.new

    CSV::Writer.generate(report) do |csv|
      questions.each_with_index { |q, i|
        csv << [ i+1, q.text ]
      }
    end
    report.rewind

    csv_filename = generate_csv_filename('absolute_pitch_survey_question_key', true)
    outFile = File.new(csv_filename, 'w')
    outFile.write(report.read)
    outFile.close
    return csv_filename
  end

  def create_absolute_pitch_survey_report_worker(work)
    aps = Survey.find_by_name("Absolute Pitch Survey")
    survey_users = User.find(:all, :conditions => 'absolute_pitch_survey_completion IS NOT NULL AND NOT is_test = true', :order => 'hex')
    questions = []
    if not aps.nil? then
      aps.survey_sections.each {|s|
        questions << s.survey_questions
      }
    end
    questions = questions.flatten.sort{|x,y| x.id <=> y.id }.select{|q| q.question_type != 'end'}

    header = ['hexid']
    questions.each_with_index {|q, i|
      header << "Question " + (i + 1).to_s
    }

    user_answers = []
    survey_users.each {|u|
      answers = [u.hex]
      questions.each_with_index {|q, i|
        answer = u.survey_answers.select { |a| a.survey_question_id == q.id }
        if answer.nil? || answer.length == 0
          answers << ''
        else
          answers << answer.map {|a| a.text}.join(";")
        end
      }
      user_answers << answers
    }

    report = StringIO.new

    CSV::Writer.generate(report) do |csv|
      csv << header
      user_answers.each {|r|
        csv << r
      }
    end
    report.rewind

    csv_filename = generate_csv_filename('absolute_pitch_survey', true)
    outFile = File.new(csv_filename, 'w')
    outFile.write(report.read)
    outFile.close
    return csv_filename
  end

  def create_exam_question_key_report_worker(work)
    buf = ''
    # first the questions
    header_row = ['Question id','Exam version id','Kind','Ordinal','Question']
    CSV.generate_row(header_row, header_row.size, buf)
    ExamQuestion.all.each do |eq|
          row = []
          row.push eq.id
          row.push eq.exam_version_id
          row.push eq.kind
          row.push eq.ordinal
          row.push eq.question
          CSV.generate_row(row, row.size, buf)
    end
    # now the answers
    header_row = ['','','','']
    CSV.generate_row(header_row, header_row.size, buf)
    header_row = ['Answer id','Question id','Correct','','Answer']
    CSV.generate_row(header_row, header_row.size, buf)
    AnswerOption.all.each do |ao|
          row = []
          row.push ao.id
          row.push ao.exam_question_id
          row.push ao.correct
          row.push '' # so as not to mess up layout too much for questions, above
          row.push ao.answer
          CSV.generate_row(row, row.size, buf)
    end
    csv_filename = generate_csv_filename('exam_question_key', true)
    outFile = File.new(csv_filename, 'w')
    outFile.write(buf)
    outFile.close
    return csv_filename
  end

  def report_worker(work)
    error_message = ''
    begin
      if work.report_name == 'exam' and work.report_type == 'csv' then
        filename = create_exam_report_worker(work)
      elsif work.report_name == 'exam_question_key' and work.report_type == 'csv' then
        filename = create_exam_question_key_report_worker(work)
      elsif work.report_name == 'enrollment' and work.report_type == 'csv' then
        filename = create_enrollment_report_worker(work)
      elsif work.report_name == 'international_users_scoreboard' and work.report_type == 'csv' then
        filename = create_international_users_scoreboard_worker(work)
      elsif work.report_name == 'international_users_list' and work.report_type == 'csv' then
        filename = create_international_users_list_worker(work)
      elsif work.report_name == 'absolute_pitch' and work.report_type == 'csv' then
        filename = create_absolute_pitch_survey_report_worker(work)
      elsif work.report_name == 'absolute_pitch_question_key' and work.report_type == 'csv' then
        filename = create_absolute_pitch_survey_question_key_report_worker(work)
      elsif work.report_name == 'user_log' and work.report_type == 'csv' then
        filename = create_user_log_report_worker(work)
      else
        error_message = "Unknown report name #{work.report_name} or type #{work.report_type}"
      end
		rescue Exception => e
      if e.to_s =~ /has gone away/ or e.to_s =~ /Lost connection/ then
        puts "MySQL went away; re-establishing connection and retrying."
        ActiveRecord::Base.establish_connection and retry
        retry
      end
      error_message = e.inspect()
			puts "Trapped exception in report_worker"
      puts "#{work.action}: job failed: #{error_message}"
    end

    if error_message == '' then
      callback('report_ready',work.user_id, { "report_id" => work.report_id, "filename" => filename })
    else
      callback('report_failed',work.user_id, { "report_id" => work.report_id, "error" => error_message })
    end
  end

  def process_file_worker(work)
    @uf = UserFile.find(work.user_file_id)

    # We got a UserFile object (with associated Dataset object)
    if  @uf.is_suitable_for_get_evidence? then
      # See if we need to upload the file to GET-Evidence first
      @uf.store_in_warehouse if @uf.locator.nil?
      if @uf.locator then
        begin
          @uf.submit_to_get_evidence!(:make_public => false,
                                      :name => "#{@uf.user.hex} (#{@uf.name})",
                                      :controlled_by => @uf.user.hex)
          @uf.update_processing_status!
        rescue
          error_message = "Unable to process file"
          callback('process_file_failed',work.user_id, { "user_file_id" => work.user_file_id, "error" => error_message } )
        end
      else
        error_message = "Unable to store in warehouse"
        callback('process_file_failed',work.user_id, { "user_file_id" => work.user_file_id, "error" => error_message } )
        return
      end
      callback('process_file_ready',work.user_id, { "user_file_id" => work.user_file_id } )
      return
    else
      error_message = "This UserFile object is not suitable for processing through GET-Evidence"
      callback('process_file_failed',work.user_id, { "user_file_id" => work.user_file_id, "error" => error_message } )
      return
    end
  end

  def process_ccr_worker(work)

    @ccr_xml = Nokogiri::XML(work.ccr_contents)
    error_message = ''
    begin
      @version, @origin = get_version_and_origin(@ccr_xml)

      @ccr_filename = get_ccr_filename(work.user_id, true, @version)
  
      outFile = File.new(@ccr_filename, 'w')
      outFile.write(work.ccr_contents)
      outFile.close
  
      # We don't want duplicates
      Ccr.find_by_user_id_and_version(work.user_id,@version).destroy unless Ccr.find_by_user_id_and_version(work.user_id,@version).nil?
  
      db_ccr = parse_xml_to_ccr_object_worker(@version,@origin,@ccr_xml)
      db_ccr.user_id = work.user_id
      db_ccr.save
 
      if !File.exist?(@ccr_filename)
        callback('userlog',work.user_id,
          { "message" => "process_ccr: Uploaded PHR (#{@ccr_filename})",
            "user_message" => "Uploaded PHR (#{@version})." } )
      else
        callback('userlog',work.user_id,
          { "message" => "process_ccr: Updated PHR (#{@ccr_filename})",
            "user_message" => "Updated PHR (#{@version})." } )
      end

    rescue Exception => e
      if e.to_s =~ /has gone away/ or e.to_s =~ /Lost connection/ then
        puts "MySQL went away; re-establishing connection and retrying."
        ActiveRecord::Base.establish_connection and retry
        retry
      end
      error_message = e.inspect()
      puts "Trapped exception in process_ccr_worker"
      puts "#{work.action}: job failed: #{error_message}"
      puts "#{e.backtrace()}"

      @user_error_message = "Failed to process PHR (#{@version})."
      if e.class == Nokogiri::XML::XPath::SyntaxError then
        @user_error_message = "Failed to process PHR: this file is not a valid CCR xml file."
      end

      callback('userlog',work.user_id,
        { "message" => "process_ccr: failed to process PHR (#{@ccr_filename})",
          "user_message" => @user_error_message } )
    end

   end

  def get_ccr_worker(work)
    client = GData::Client::Base.new
    client.authsub_token = work.authsub_token
    client.authsub_private_key = private_key
    if work.etag
      client.headers['If-None-Match'] = work.etag
    end
    feed = client.get(work.ccr_profile_url).body
    ccr = Nokogiri::XML(feed)
    updated = ccr.xpath('/xmlns:feed/xmlns:updated').inner_text

    if (updated == '1970-01-01T00:00:00.000Z') then
      callback('userlog',work.user_id,
        { "message" => "get_ccr: PHR at Google Health is empty, it has not been downloaded.", 
          "user_message" => "Your PHR at Google Health is empty, it has not been downloaded." } )
      return
    end

    ccr_filename = get_ccr_filename(work.user_id, true, updated)
    if !File.exist?(ccr_filename)
      callback('userlog',work.user_id, 
        { "message" => "get_ccr: Downloaded PHR (#{ccr_filename})", 
          "user_message" => "Downloaded PHR." } )
    else
      callback('userlog',work.user_id, 
        { "message" => "get_ccr: Downloaded and replaced PHR (#{ccr_filename})", 
          "user_message" => "Updated PHR." } )
    end
    outFile = File.new(ccr_filename, 'w')
    outFile.write(feed)
    outFile.close
    callback('ccr_downloaded',work.user_id, { "updated" => updated, "ccr_filename" => ccr_filename })
  end

	def get_ccr(user_id, authsub_token, etag, ccr_profile_url)
		work = WorkObject.new()
		work.action = 'get_ccr'
		work.authsub_token = authsub_token
		work.etag = etag
		work.ccr_profile_url = ccr_profile_url
		work.user_id = user_id
		@queue.enq(work)
		return 0
	end

	def process_ccr(user_id, ccr_contents)
		work = WorkObject.new()
		work.action = 'process_ccr'
		work.user_id = user_id
		work.ccr_contents = ccr_contents
		@queue.enq(work)
		return 0
	end

   def process_file(user_id, user_file_id)
    work = WorkObject.new()
    work.action = 'process_file'
    work.user_id = user_id
    work.user_file_id = user_file_id
    @queue.enq(work)
    return 0
  end

  def create_report(user_id,report_id,report_name,report_type,filter='')
    work = WorkObject.new()
    work.action = 'report'
    work.user_id = user_id
    work.report_id = report_id.to_s
    work.report_name = report_name
    work.report_type = report_type
    work.filter = filter
    @queue.enq(work)
    return 0
  end

	def callback(type,user_id,args) 
	
    if args.class == Hash then
      params = "?"
      args.each do |k,v|
   		  params += "#{k}=" + CGI.escape(v.to_s) + "&" 
      end
      params += "user_id=#{user_id}"
    else
 		  params = "/#{user_id}?message=" + CGI.escape(args.to_s)
    end

    url = "http://#{@config['callback_host']}:#{@config['callback_port']}/drb/#{type}#{params}"

		# Do callback
		puts "Calling #{url}"
 		Net::HTTP.get URI.parse(url)
	end

	def pretty_size(size)
		return nil if size.nil?
		if size.to_i > 1024 then
			# KB
			size = (size / 1024)
			if size.to_i > 1024 then
				# MB
				size = (size / 1024)
				if size.to_i > 1024 then
					size = (size / 1024)
					if size.to_i > 1024 then
						# GB
						size = (size / 1024)
						if size.to_i > 1024 then
							# TB
							size = (size / 1024)
						else
							return sprintf("%8.2f T",size)
						end
					else
						return sprintf("%8.2f G",size)
					end
				else
					return sprintf("%8.2f M",size)
				end
			else
				return sprintf("%8.2f K",size)
			end
		else
			return sprintf("%5d     ",size)
		end
	end

  # Returns location of private key used to sign Google Health requests
  def private_key
    if File.exists?(File.dirname(__FILE__) + '/../config/private_key.pem')
      return File.dirname(__FILE__) + '/../config/private_key.pem'
    else
      return nil
    end
  end

end


