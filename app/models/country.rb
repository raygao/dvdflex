class Country < ActiveRecord::Base
  validates_presence_of :code
  validates_presence_of :description
end
