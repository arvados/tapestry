require 'shellwords'
require 'test_helper'

class ArvadosJobTest < ActiveSupport::TestCase
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
end
