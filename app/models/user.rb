class User < ActiveRecord::Base
  include FacebookerAuthentication::Model
  has_many :listings,
    :dependent => :destroy
end
