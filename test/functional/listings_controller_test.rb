require 'test_helper'
require 'listings_controller'
include Facebooker::Rails::TestHelpers

class ListingsControllerTest < ActionController::TestCase
   fixtures :listings, :dvds, :users
  
  def test_index
    facebook_get :index
    assert_response :success
    assert_template 'index'

  end

  def test_show_listings
    facebook_get :index, :id => 1
    assert_response :success
    assert_template 'index'

    assert_not_nil @listing = listings(:guestfavorite)

    assert_not_nil assigns(:listings)
    puts " note of the guest favorite is: " + @listing.note
  end
  
=begin
  def test_index_not_logged_on
    assert true
    facebook_get :index, :fb_sig_user => nil
    assert_response :success
    # assert_template 'index'
    assert_facebook_redirect_to Facebooker::Session.create.login_url
  end
=end

end
