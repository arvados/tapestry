class Dataset < ActiveRecord::Base
  acts_as_versioned

  belongs_to :participant, :class_name => 'User'

  # implement "genetic data" interface
  def date
    "N/A"
  end
  def data_type
    "Whole Genome or Exome"
  end
  def download_url
    "http://evidence.personalgenomes.org/genome_download.php?download_genome_id=#{sha1}&download_nickname=#{CGI::escape(name)}"
  end
end
