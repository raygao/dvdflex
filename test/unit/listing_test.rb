require 'test_helper'

class ListingTest < ActiveSupport::TestCase

  def test_invalid_with_empty_attributes
    listing = Listing.new
    # an empty valid model should be invalid
    assert !listing.valid?
    # the user & dvd_id fields should have validation errors
    assert(listing.errors.invalid?(:user), 'listing cannot be created without an associated user')
    assert(listing.errors.invalid?(:dvd), 'listing cannot be created with a null DVD Id')
    # the body field should have validation errors
    assert(!listing.save, 'invalid listing cannot be saved.')
  end

  def test_create_a_valid_listing
    listing = Listing.new
    listing.user = User.find(:first)
    listing.dvd = Dvd.find(:first)
    #assert (listing.valid?, 'Listing is valid')
    #assert(listing.save, 'Only listing with valid information can be saved.')
  end


end
