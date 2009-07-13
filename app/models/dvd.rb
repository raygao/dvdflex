class Dvd < ActiveRecord::Base
  validates_presence_of :upc
  validates_uniqueness_of :upc
  has_many :listings, :dependent => :nullify
  has_many :torrents, :dependent => :destroy

  belongs_to :country
  has_one :imdblisting

end