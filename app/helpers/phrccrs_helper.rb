# Methods added to this helper will be available to all templates in the application.
# Copyright (C) 2008 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'cgi'
require 'openssl'
require 'base64'

module PhrccrsHelper
    # This is a modification of the AuthSub class to handle generate correct Health/H9 requests
    # This class implements AuthSub signatures for Data API requests.
    # It can be used with a GData::Client::GData object.
    class AuthSub

      # The URL of AuthSubRequest.
      H9_REQUEST_HANDLER = 'https://www.google.com/h9/authsub'
      HEALTH_REQUEST_HANDLER = 'https://www.google.com/health/authsub'

      # Return the proper URL for an AuthSub approval page with the requested
      # scope. next_url should be a URL that points back to your code that
      # will receive the token. domain is optionally a Google Apps domain.
      def self.get_url(next_url, scope, secure = false, session = true,
          domain = nil)
        next_url = CGI.escape(next_url)
        scope = CGI.escape(scope)
        secure = secure ? 1 : 0
        session = session ? 1 : 0
        body = "next=#{next_url}&scope=#{scope}&session=#{session}" +
               "&secure=#{secure}"
        if domain
          domain = CGI.escape(domain)
          body = "#{body}&hd=#{domain}"
        end
        if scope.index('h9')
          return "#{H9_REQUEST_HANDLER}?#{body}&permission=1"
        else
          return "#{HEALTH_REQUEST_HANDLER}?#{body}&permission=1"
        end
      end
  end

  def get_dob_age(dob)
    #rails populates null DateTime with today's date
    return '' if Date.today == dob
    if (dob)
      now = DateTime.now
      a = now.year - dob.year - 1
      if now.month > dob.month || now.month == dob.month && now.day >= dob.day
        a = a + 1
      end
      return dob.to_s + ' (' + a.to_s + ' years old)'
    end
  end

  # View helper method to display DOB and Age
  def dob_to_dob_age(dob_s)
    if (dob_s && dob_s != '')
      begin
        dob = Date.parse(dob_s.text)
      rescue
        return ''
      end
      now = DateTime.now
      a = now.year - dob.year - 1
      if now.month > dob.month || now.month == dob.month && now.day >= dob.day
        a = a + 1
      end
      return dob_s.text + ' (' + a.to_s + ' years old)'
   end
   return ''
  end

  def normalize_to_oz(value, unit)
    return '' if value.nil?
    value = value.text
    unit = unit.text
    if ['oz', 'ounce', 'ounces'].include?(unit)
      return value.to_f
    elsif ['lb', 'lbs', 'pounds', 'pound'].include?(unit)
      return value.to_f * 16
    elsif ['kg', 'kgs', 'kilogram', 'kilograms'].include?(unit)
      return value.to_f * 35.2739619
    elsif ['g', 'gram', 'grams'].include?(unit)
      return value.to_f * 0.0352739619
    else
      return value.to_f
    end
  end

  def normalize_to_in(value, unit)
    return '' if value.nil?
    value = value.text
    unit = unit.text
    if ['in', 'inches', 'inch'].include?(unit)
      return value.to_f
    elsif ['ft', 'feet'].include?(unit)
      return value.to_f * 12
    elsif ['cm', 'centimeter', 'centimeters'].include?(unit)
      return value.to_f * 0.393700787
    elsif ['m', 'meter', 'meters'].include?(unit)
      return value.to_f * 39.3700787
    else
      return value.to_f
    end
  end

  # View helper method to display weight in pounds and kilograms
  def oz_to_lbs_kg(oz)
    if (oz && oz !=  '' && oz != 0)
      oz = oz.to_f
      return (oz / 16).to_i.to_s + 'lbs (' + (oz / 35.2739619).to_i.to_s + 'kg)'
    end
    return ''
  end

  # View helper method to display height in feet and centimeters
  def in_to_ft_in_cm(inches)
    if (inches && inches != '' && inches != 0)
      inches = inches.to_i
      ft = [inches / 12, inches % 12]
      s = ft[0].to_s + 'ft'
      if ft[1] > 0
        s = s + ' ' + ft[1].to_s + 'in'
      end
      return s + ' (' + (inches / 0.393700787).to_i.to_s + 'cm)'
    end
    return ''
  end

  def dose_frequency(dose, frequency)
    if dose.class == String || frequency.class == String
      s = ''
      if dose && !dose.empty?
        s = 'Take ' + dose
      end
      if dose && !dose.empty? && frequency && !frequency.empty?
        s = s + ', '
      end
      if frequency && !frequency.empty?
        s = s + frequency
      end
      logger.error 'ccr object: ' + s
      return s
    end
    return ''
  end

  def get_ccr_path(user_id)
    user_id = user_id.to_s
    if user_id.length % 2 == 1
      user_id = '0' + user_id
    end
    f = "/data/#{ROOT_URL}/ccr/"

    while user_id.length > 0
      f = f + user_id[0,2]
      f = f + '/'
      user_id = user_id[2, user_id.length]
    end

    return f
  end

  # Returns filename of ccr based on user's id
  # File is based on a left-padded user id divided into 2 digit chunks
  # e.g. User id : 12345 => 01/23/45/ccr.xml
  #      User id : 314159 => 31/41/59/ccr.xml
  def get_ccr_filename(user_id, create_dir = true, timestamp = '')
    user_id = user_id.to_s
    if user_id.length % 2 == 1
      user_id = '0' + user_id
    end
    f = "/data/#{ROOT_URL}/ccr/"

    while user_id.length > 0
      f = f + user_id[0,2]
      if create_dir && !File.directory?(f)
        Dir.mkdir(f)
      end
      f = f + '/'
      user_id = user_id[2, user_id.length]
    end

    return f + "ccr#{timestamp}.xml"
  end

  def show_date(n)
    unless n && n.length > 0
      return ''
    end
    return n[0].inner_text[0,10]
  end

  # Returns location of private key used to sign Google Health requests
  def private_key
    return 'config/pgpenrollkey.pem'
  end

  def ccr_profile_url
    return GOOGLE_HEALTH_URL + '/feeds/profile/default'
  end

  def authsub_revoke(current_user)
    authsubRequest = GData::Auth::AuthSub.new(current_user.authsub_token)
    authsubRequest.private_key = private_key
    authsubRequest.revoke
  rescue GData::Client::Error => ex
    #Ignore AuthorizationError because it most likely means the token was invalidated by the user through Google
  ensure
    current_user.update_attributes(:authsub_token => '')   
  end

  def get_ccr(current_user, etag = nil)
    client = GData::Client::Base.new
    client.authsub_token = current_user.authsub_token
    client.authsub_private_key = private_key
    if etag
      client.headers['If-None-Match'] = etag
    end
    feed = client.get(ccr_profile_url).body
    return feed
  end

  # This is ugly, but it is about 50 times faster than
  # @ccr.xpath('/xmlns:feed/xmlns:entry[xmlns:category[@term="LABTEST"]]//ccr:Results/ccr:Result').each { |result| 
  # This matters a lot when you have a large PHR.
  # Ward, 2010-09-21
  def get_results(ccr,cat,field)
    r = Array.new()

    sortstr = 'ccr:Test/ccr:DateTime[ccr:Type/ccr:Text="Collection start date"]/ccr:ExactDateTime'
    sortstr = 'ccr:DateTime[ccr:Type/ccr:Text="Start date"]/ccr:ExactDateTime' if cat == 'PROCEDURE'

    ccr.xpath('/xmlns:feed/xmlns:entry[xmlns:category[@term="' + cat + '"]]').each do |entry| 
      entry.children.each do |child|
        if child.name == 'ContinuityOfCareRecord' then
          child.children.each do |c2|
            if c2.name == 'Body' then
              c2.children.each do |c3|
                if c3.name == field + 's' then
                  c3.children.each do |result|
                    next if result.name != field
                    r.push(result)
                  end 
                end 
              end 
            end 
          end 
        end 
      end 
    end 
    r.sort! {|x,y| show_date(x.xpath(sortstr)) <=> show_date(y.xpath(sortstr)) }

    return r
  end

  def get_elements(node, name)
    a = []
    node.children.each { |c|
      if c.name == name
	a << c
      end
    }
    return a
  end

  def get_element(node, name)
    return nil if node.nil?
    node.children.each { |c|
      if c.name == name
	return c
      end
    }
    return nil
  end

  def get_element_text(node, name)
    n = get_element(node, name)
    return n.nil? ? nil : n.inner_text
  end

  def get_date_element(node, name)
    return nil if node.nil?
    node.children.each { |c|
      if c.name == 'DateTime'
      	t = get_element(c, 'Type')
	next if t.nil?
	tx = get_element(t, 'Text')
	tx_s = tx.inner_text
	next if tx.nil? || tx_s != name
	edt = get_element(c, 'ExactDateTime')
	return nil if edt.nil?
	edt_text = edt.inner_text
	return nil if edt_text == '--T00:00:00Z'
	if edt_text.length == 4
	  edt_text += '-01-01' #Append dummy date for entries with just the year
        end
	return DateTime.parse(edt_text)
      end
    }
    return nil
  end

  def get_codes(d)
    codes = get_elements(d, 'Code') unless d.nil?
    cs = ''
    unless codes.nil?
      codes.each { |c|
        cs += get_element_text(c, 'Value') + ':' + get_element_text(c, 'CodingSystem') + ';'
      }
    end
    return cs
  end

  def get_inner_text(n)
    return n.nil? ? nil : n.inner_text
  end

  def get_status(n)
    s = get_element(n, 'Status')
    return s.nil? ? nil : get_element_text(s, 'Text')
  end

  def get_first(n)
    if n && n.length > 1
      return n[0]
    end
    return n
  end

  def parse_xml_to_ccr_object(ccr_file)
    feed = File.open(ccr_file, 'r')
    ccr_xml = Nokogiri::XML(feed)
    ccr = Ccr.new
    conditions = []
    medications = []
    immunizations = []
    lab_test_results = []
    allergies = []
    procedures = []

    ccr.version = get_inner_text(ccr_xml.xpath('/xmlns:feed/xmlns:updated'))
    
    dem = Demographic.new
    dob = get_first(ccr_xml.xpath('//ccr:Actors/ccr:Actor/ccr:Person/ccr:DateOfBirth/ccr:ExactDateTime'))
    begin
      if dob.nil?
        dem.dob = nil
      else
        dob_s = get_inner_text(dob) 
        dem.dob = dob_s == '--T00:00:00Z' ? nil : DateTime.parse(dob_s)
      end	 
    rescue
      dem.dob = nil
    end
    gender = get_first(ccr_xml.xpath('//ccr:Actors/ccr:Actor/ccr:Person/ccr:Gender/ccr:Text'))
    dem.gender = get_inner_text(gender)
    weight = get_first(ccr_xml.xpath('//ccr:VitalSigns/ccr:Result/ccr:Test[ccr:Description/ccr:Text="Weight"][1]/ccr:TestResult/ccr:Value'))
    weight_unit = get_first(ccr_xml.xpath('//ccr:VitalSigns/ccr:Result/ccr:Test[ccr:Description/ccr:Text="Weight"][1]/ccr:TestResult/ccr:Units/ccr:Unit'))
    dem.weight_oz = normalize_to_oz(weight, weight_unit)
    height = get_first(ccr_xml.xpath('//ccr:VitalSigns/ccr:Result/ccr:Test[ccr:Description/ccr:Text="Height"][1]/ccr:TestResult/ccr:Value'))
    height_unit = get_first(ccr_xml.xpath('//ccr:VitalSigns/ccr:Result/ccr:Test[ccr:Description/ccr:Text="Height"][1]/ccr:TestResult/ccr:Units/ccr:Unit'))
    dem.height_in = normalize_to_in(height, height_unit)
    blood_type = get_first(ccr_xml.xpath('//ccr:VitalSigns/ccr:Result/ccr:Test[ccr:Description/ccr:Text="Blood Type"][1]/ccr:TestResult/ccr:Value'))
    dem.blood_type = get_inner_text(blood_type)
    race = ''
    race_node = get_first(ccr_xml.xpath('//ccr:SocialHistory/ccr:SocialHistoryElement[ccr:Type/ccr:Text="Race"][1]'))
    race_node.xpath('ccr:Description/ccr:Text').each_with_index { |r,i|
      if i > 0
        race += ', '
      end
      race += get_inner_text(r)
    }
    dem.race = race

    get_results(ccr_xml,'MEDICATION','Medication').each { |medication|
      o = Medication.new
      o.dose = ''
      o.strength = ''
      product = get_element(medication, 'Product')
      o.start_date = get_date_element(medication, 'Start date')
      o.start_date = get_date_element(medication, 'Prescription Date') if o.start_date.nil?
      o.end_date = get_date_element(medication, 'End date')
      d = get_element(product, 'ProductName')

      name = get_element_text(d, 'Text') unless d.nil?
      #skip if invalid item (occurs frequently on CCR exported by BCBS
      next if name.nil? || name.empty?
      medication_name = MedicationName.new
      medication_name.name = name

      # if unsuccessful save, medication is already in db due to uniqueness constraint       
      begin
        medication_name.save
      rescue
        medication_name = MedicationName.find_by_name(name)
      end

      o.medication_name_id = medication_name.id
      o.codes = get_codes(d)
      o.status = get_status(medication)
      
      strength = get_element(product, 'Strength')
      o.strength = get_element_text(strength, 'Value') unless strength.nil?
      u = get_element(strength, 'Units') unless strength.nil?
      uv = get_element(u, 'Unit') unless u.nil?
      o.strength += ' ' + get_inner_text(uv) unless uv.nil?

      form = get_element(product, 'Form')
      form_text = get_element_text(form, 'Text')
      if o.strength.nil?
        o.strength = form_text
      elsif !form_text.nil?
        o.strength += ' ' + form_text
      end
      
      directions = get_element(medication, 'Directions')
      direction = get_element(directions, 'Direction') unless directions.nil?
      dose = get_element(direction, 'Dose')
      o.dose = get_element_text(dose, 'Value')

      route = get_element(direction, 'Route') unless direction.nil?
      o.route = get_element_text(route, 'Text')
      o.route_codes = get_codes(route)

      frequency = get_element(direction, 'Frequency')
      o.frequency = get_element_text(frequency, 'Value')

      medications << o
    }      

    get_results(ccr_xml,'ALLERGY','Alert').each { |allergy|
      o = Allergy.new
      o.start_date = get_date_element(allergy, 'Start date')
      o.end_date = get_date_element(allergy, 'Stop date')
      d = get_element(allergy, 'Description')
      description = get_element_text(d, 'Text') unless d.nil?
      #skip if invalid item (occurs frequently on CCR exported by BCBS
      next if description.nil? || description.empty?
      allergy_description = AllergyDescription.new
      allergy_description.description = description

      # if unsuccessful save, allergy is already in db due to uniqueness constraint       
      begin
        allergy_description.save
      rescue
        allergy_description = AllergyDescription.find_by_description(description)
      end

      o.allergy_description_id = allergy_description.id
      o.codes = get_codes(d)
      o.status = get_status(allergy)
      r = get_element(allergy, 'Reaction')
      s = get_element(r, 'Severity') unless r.nil?
      o.severity = get_element_text(s, 'Text') unless s.nil?
      allergies << o
    }

    get_results(ccr_xml,'CONDITION','Problem').each { |problem|
      o = Condition.new
      o.start_date = get_date_element(problem, 'Start date')
      o.end_date = get_date_element(problem, 'Stop date')
      d = get_element(problem, 'Description')
      o.status = get_status(problem)
      description = get_element_text(d, 'Text') unless d.nil?
      #skip if invalid item (occurs frequently on CCR exported by BCBS
      next if description.nil? || description.empty?
      condition_description = ConditionDescription.new
      condition_description.description = description

      # if unsuccessful save, condition is already in db due to uniqueness constraint       
      begin
	condition_description.save
      rescue
        condition_description = ConditionDescription.find_by_description(description)
      end

      o.condition_description_id = condition_description.id
      o.codes = get_codes(d)
      conditions << o
    }

    get_results(ccr_xml,'IMMUNIZATION','Immunization').each { |immunization|
      o = Immunization.new
      o.start_date = get_date_element(immunization, 'Start date')
      p = get_element(immunization, 'Product')
      d = get_element(p, 'ProductName')

      name = get_element_text(d, 'Text') unless d.nil?
      #skip if invalid item (occurs frequently on CCR exported by BCBS
      next if name.nil? || name.empty?
      immunization_name = ImmunizationName.new
      immunization_name.name = name

      # if unsuccessful save, immunization is already in db due to uniqueness constraint       
      begin
        immunization_name.save
      rescue
        immunization_name = ImmunizationName.find_by_name(name)
      end

      o.immunization_name_id = immunization_name.id
      o.codes = get_codes(d)
      immunizations << o
    }
     
    get_results(ccr_xml,'LABTEST','Result').each { |result|
      o = LabTestResult.new
      t = get_element(result, 'Test')
      d = get_element(t, 'Description')
      description = get_element_text(d, 'Text') unless d.nil?
      #skip if invalid item (occurs frequently on CCR exported by BCBS
      next if description.nil? || description.empty?
      lab_test_result_description = LabTestResultDescription.new
      lab_test_result_description.description = description

      # if unsuccessful save, assume lab test is already in db due to uniqueness constraint
      begin
	lab_test_result_description.save
      rescue
        lab_test_result_description = LabTestResultDescription.find_by_description(description)
      end

      o.lab_test_result_description_id = lab_test_result_description.id

      tr = get_element(t, 'TestResult')
      u = tr.nil? ? nil : get_element(tr, 'Units')
      o.value = get_element_text(tr, 'Value') unless tr.nil?
      o.units = get_element_text(u, 'Unit') unless u.nil?
      o.start_date = get_date_element(t, 'Collection start date')
      o.codes = get_codes(d)
      lab_test_results << o
    }
    
    get_results(ccr_xml,'PROCEDURE','Procedure').each { |procedure|
      o = Procedure.new
      d = get_element(procedure, 'Description')
      description = get_element_text(d, 'Text') unless d.nil?
      #skip if invalid item (occurs frequently on CCR exported by BCBS
      next if description.nil? || description.empty?
      procedure_description = ProcedureDescription.new
      procedure_description.description = description

      # if unsuccessful save, procedure is already in db due to uniqueness constraint       
      begin
        procedure_description.save
      rescue
        procedure_description = ProcedureDescription.find_by_description(description)
      end

      o.procedure_description_id = procedure_description.id
      o.start_date = get_date_element(procedure, 'Start date')
      o.codes = get_codes(d)
      procedures << o
    }

    ccr.demographic = dem
    ccr.allergies = allergies
    ccr.procedures = procedures
    ccr.medications = medications
    ccr.conditions = conditions
    ccr.immunizations = immunizations
    ccr.lab_test_results = lab_test_results
    #logger.error '>> allergies: ' + allergies.length.to_s
    #logger.error '>> procedures: ' + procedures.length.to_s
    #logger.error '>> medications: ' + medications.length.to_s
    #logger.error '>> conditions: ' + conditions.length.to_s
    #logger.error '>> immunizations: ' + immunizations.length.to_s
    #logger.error '>> lab test results: ' + lab_test_results.length.to_s
    return ccr
  end

end
