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

  # View helper method to display DOB and Age
  def dob_to_dob_age(dob_s)
    if (dob_s && !dob_s.empty?)
      dob = Date.parse(dob_s.text)
      now = DateTime.now
      a = now.year - dob.year - 1
      if now.month > dob.month || now.month == dob.month && now.day >= dob.day
        a = a + 1
      end
      return dob_s.text + ' (' + a.to_s + ' years old)'
   end
   return ''
  end

  # View helper method to display weight in pounds and kilograms
  def oz_to_lbs_kg(oz)
    if (oz && !oz.empty?)
      oz = oz.text.to_i
      return (oz / 16).to_s + 'lbs (' + (oz / 35.2739619).to_i.to_s + 'kg)'
    end
    return ''
  end

  # View helper method to display height in feet and centimeters
  def in_to_ft_in_cm(inches)
    if (inches && !inches.empty?)
      inches = inches.text.to_i
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
    s = ''
    if dose && !dose.empty?
      s = 'Take ' + dose.text
    end
    if dose && !dose.empty? && frequency && !frequency.empty?
      s = s + ', '
    end
    if frequency && !frequency.empty?
      s = s + frequency.text
    end
    return s
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

  def health_url
    if ROOT_URL == "enroll.personalgenomes.org"
      return "https://www.google.com/health"
    else
      return "https://www.google.com/h9"
    end
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
    return health_url + '/feeds/profile/default'
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
    return r
  end

end
