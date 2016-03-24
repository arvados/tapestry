require 'shellwords'

class ArvadosJob < ActiveRecord::Base
  acts_as_versioned

  class ArvadosAPIError < StandardError
  end

  ##
  # Start a pipeline.
  #
  # +opts[:pipeline_template_file]+ is the template to run, relative
  # to Rails.root.
  #
  # +opts[:component_parameters]+ is a hash of component parameters to
  # pass to arv-run-pipeline-instance.
  #
  # +opts[:project_uuid]+ (optional) is the project where the pipeline
  # should run.
  #
  # +opts[:description]+ (optional) is the description field for the
  # new pipeline instance.
  #
  # Returns a new saved ArvadosJob instance, or raises an exception if
  # it cannot be created.
  def self.run_pipeline opts
    cmd = ['arv-run-pipeline-instance']
    cmd << '--submit'
    cmd << '--template' << Rails.root.join(opts[:pipeline_template_file]).to_s
    cmd << '--project-uuid' << opts[:project_uuid] if opts[:project_uuid]
    cmd << '--description' << opts[:description] if opts[:description]
    (opts[:inputs] || {}).each do |k,v|
      cmd << k + "=" + v
    end
    cmd = (APP_CONFIG['ruby19_shell_args'] || []) + cmd

    uuid = nil
    IO.popen(cmd.map(&:shellescape).join(' ')) do |io|
      uuid = io.read.strip
    end
    if $?.exitstatus != 0
      raise ArvadosAPIError, $?.inspect
    end
    create!(:uuid => uuid,
            :oncomplete => opts[:oncomplete],
            :onerror => opts[:onerror])
  end

  def resolve
    process_callback :oncomplete
    destroy
  end

  def reject
    process_callback :onerror
    destroy
  end

  ##
  # Return a generic callback that notifies admin about errors.
  def self.generic_error_callback
    return 'proc { |job| UserMailer.arvados_job_failure(job).deliver }'
  end

  protected

  ##
  # Process callback +callback_type+ (either :oncomplete or :onerror).
  def process_callback callback_type
    callback_string = send callback_type
    return true if callback_string.nil?
    callback = eval callback_string
    while callback.is_a? Proc
      callback = callback.call self
    end
    callback
  end
end
