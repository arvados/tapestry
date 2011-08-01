class KitObserver < ActiveRecord::Observer
  observe :kit

  # Ensure associated kit design and kit design samples are frozen if this kit is marked as sent
  def after_update(kit)
    if not kit.last_mailed.nil? then
      kit.kit_design.frozen = true
      kit.kit_design.save
      kit.kit_design.samples.each do |kds|
        kds.frozen = true
        kds.save
      end
    end
  end

  # Make sure to create the samples that belong in the kit
  def after_create(kit)
    kit.kit_design.samples.each do |kds|
      s = Sample.new()
      s.name = kds.name
      s.study = kit.study
      s.kit = kit
      s.crc_id = Kit.generate_verhoeff_number(s)
      s.url_code = Kit.generate_url_code(s)
      s.original_kit_design_sample_id = kds.id
      s.kit_design_sample_id = kds.id
      s.owner = kit.owner
      s.amount = kds.target_amount
      s.unit = kds.unit
      s.material = kds.tissue
      s.save
STDERR.puts      s.errors.to_s
      SampleLog.new(:actor => kit.owner, :comment => 'Sample created', :sample_id => s.id).save
    end
  end

end
