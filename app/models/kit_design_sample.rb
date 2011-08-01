class KitDesignSample < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  validates_presence_of    :name
  validates_uniqueness_of  :name

  validates_presence_of    :description
  validates_presence_of    :kit_design_id

  validates_numericality_of    :sort_order
  validates_presence_of    :sort_order

  belongs_to :kit_design

  def editable?
    not self.frozen
  end

end
