class FixBaselineTraitStepTitleAndDescription < ActiveRecord::Migration
  def self.up
    update "update enrollment_steps set description='Trait Data',title='Trait Data' where keyword='baseline_trait_collection_notification'";
  end

  def self.down
    update "update enrollment_steps set description='Baseline Trait Data',title='Baseline Trait Data' where keyword='baseline_trait_collection_notification'";
  end
end
