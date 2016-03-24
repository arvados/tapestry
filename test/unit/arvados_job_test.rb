require 'shellwords'
require 'test_helper'

class ArvadosJobTest < ActiveSupport::TestCase

  EXAMPLE_UUID = 'zzzzz-zzzzz-0000099999eeeee'

  test "run pipeline" do
    json_file = 'test/fixtures/example_pipeline_template.json'
    # Accomplish side effect of setting $? to a successful status:
    IO.popen('true') { |io| io.read }
    IO.expects(:popen).
      with("rvm-exec 1.9.3 arv-run-pipeline-instance --submit --template " +
           Rails.root.join(json_file).to_s.shellescape +
           " --description foo\\ bar" +
           " foo::input\\=waz\\ qux").
      yields(StringIO.new("zzzzz-p5p6p-00000aaaaazzzzz\n"))
    oncomplete = '$stderr.puts "oncomplete callback"'
    onerror = '$stderr.puts "onerror callback"'
    j = ArvadosJob.run_pipeline(:pipeline_template_file => json_file,
                                :description => 'foo bar',
                                :oncomplete => oncomplete,
                                :onerror => onerror,
                                :inputs => {
                                  "foo::input" => "waz qux",
                                })
    assert j.valid?
    assert_equal 'zzzzz-p5p6p-00000aaaaazzzzz', j.uuid
    assert_equal oncomplete, j.oncomplete
    assert_equal onerror, j.onerror
    assert_equal({}, j.changes, 'ArvadosJob should have been saved')
  end

  [[:resolve, :oncomplete, :onerror],
   [:reject, :onerror, :oncomplete],
  ].each do |resolve_or_reject, callback_do, callback_dont|
    test "#{resolve_or_reject} invokes #{callback_do} callback" do
      j = ArvadosJob.create!(:uuid => EXAMPLE_UUID,
                             callback_do => 'proc { |job| ArvadosJobTest.test_callback(1234, job) }',
                             callback_dont => 'proc { |job| ArvadosJobTest.test_wrong_callback(1234, job) }')
      ArvadosJobTest.expects(:test_wrong_callback).never
      ArvadosJobTest.expects(:test_callback).once.with do |customparam, job|
        customparam == 1234 &&
          job.id == j.id &&
          job.uuid == EXAMPLE_UUID
      end
      j.send resolve_or_reject
      assert j.destroyed?
    end
  end

  [:resolve, :reject].each do |resolve_or_reject|
    test "#{resolve_or_reject} without callback" do
      j = ArvadosJob.create!(:uuid => EXAMPLE_UUID)
      j.send resolve_or_reject
      assert j.destroyed?
    end
  end

  test "generic error callback" do
    j = ArvadosJob.create!(:uuid => EXAMPLE_UUID,
                           :oncomplete => 'proc { |job| "oncomplete stub" }',
                           :onerror => ArvadosJob.generic_error_callback)
    j.reject
    assert_equal 1, ActionMailer::Base.deliveries.size
    delivery = ActionMailer::Base.deliveries.first
    assert_equal [ADMIN_EMAIL.sub(/^.*<(.+)>$/, '\1')], delivery.to
    assert_match /curover\.se\/#{EXAMPLE_UUID}/, delivery.body
    assert_match /"oncomplete stub"/, delivery.body
  end
end
