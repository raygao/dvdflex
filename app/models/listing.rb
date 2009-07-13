class Listing < ActiveRecord::Base
  belongs_to :user
  belongs_to :dvd

  validates_presence_of :dvd
  validates_presence_of :user

  after_create :update_profile

  def update_profile
    UserPublisher.deliver_profile_update(self.user)
  end

  def self.find_for_friends(friends_facebook_ids)
    # find listings of all friends, which comes in as an array
    Listing.find(:all,
      :conditions=>["users.facebook_id in (?)", friends_facebook_ids],
      :include=>[:user],
      :limit=>200,
      :order=>"status desc")
  end

  def self.find_for_a_friend(friend_facebook_id)
    # find listing of a specific friend with his fb_id.
    Listing.find(:all,
      :conditions=>["users.facebook_id in (?)", friend_facebook_id],
      :include=>[:user],
      :order=>"status desc")
  end
end
