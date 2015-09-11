require 'test_helper'

class GoogleSpreadsheetTest < ActiveSupport::TestCase
  EXAMPLE_SPREADSHEET_URL = 'https://docs.google.com/spreadsheets/d/1oC0Q-sW6IDu1gWwL_nYJdnvS8XCihr56QGStOUmHYcY/edit#gid=1930547629'
  setup do
    @token = Factory(:google_oauth_token)
    @sample1 = Factory(:sample)
    @sample2 = Factory(:sample)
  end

  test 'synchronize spreadsheet content using mock' do
    OauthToken.any_instance.stubs(:oauth2_request).
      with('GET', 'https://spreadsheets.google.com/feeds/download/spreadsheets/Export',
           'key' => '1oC0Q-sW6IDu1gWwL_nYJdnvS8XCihr56QGStOUmHYcY',
           'gid' => '1930547629',
           'exportFormat' => 'csv').
      returns stub(:status => 200,
                   :body => "hdr1,hdr2\n" +
                   "#{@sample1.crc_id},\"sample1-qc-result\"\n" +
                   "#{@sample2.crc_id},sample2-qc-result\n" +
                   "bogus-crc-id,bogus-qc-result\n")
    gs = GoogleSpreadsheet.new(:oauth_service => @token.oauth_service,
                               :user => @token.user,
                               :gdocs_url =>  EXAMPLE_SPREADSHEET_URL,
                               :rowtarget_type => 'Sample',
                               :rowtarget_id_attribute => 'crc_id',
                               :rowtarget_data_attribute => 'qc_result')
    nOK, nAttempt, err = gs.synchronize!
    assert_equal nil, err
    assert_equal 3, nAttempt
    assert_equal 2, nOK
    @sample1.reload
    @sample2.reload
    assert_equal({'hdr1' => @sample1.crc_id.to_s, 'hdr2' => 'sample1-qc-result'}, @sample1.qc_result)
    assert_equal({'hdr1' => @sample2.crc_id.to_s, 'hdr2' => 'sample2-qc-result'}, @sample2.qc_result)
  end

  test 'synchronize spreadsheet failure' do
    OauthToken.any_instance.stubs(:oauth2_request).
      returns stub(:status => 403,
                   :body => "",
                   :message => "Not Authorized")
    gs = GoogleSpreadsheet.new(:oauth_service => @token.oauth_service,
                               :user => @token.user,
                               :gdocs_url =>  EXAMPLE_SPREADSHEET_URL)
    nOK, nAttempt, err = gs.synchronize!
    assert_equal 0, nOK
    assert_equal 0, nAttempt
    assert_match /.*403 Not Authorized.*/, err
  end

  test 'synchronize spreadsheet failure, no token' do
    @token.destroy
    gs = GoogleSpreadsheet.new(:oauth_service => @token.oauth_service,
                               :user => @token.user,
                               :gdocs_url =>  EXAMPLE_SPREADSHEET_URL)
    nOK, nAttempt, err = gs.synchronize!
    assert_equal 0, nOK
    assert_equal 0, nAttempt
    assert_match /I do not have authorization.*/, err
  end
end
