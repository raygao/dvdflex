require 'test_helper'
require 'dvds_controller'


include Facebooker::Rails::TestHelpers

class DvdsControllerTest < ActionController::TestCase
  fixtures :dvds

  # Not needed since Rails 2.2, the followings are automatically provided.
=begin
  def setup
    @controller = DvdsController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end
=end

  def test_dvd_routings
    assert_routing '/dvds', :controller => 'dvds', :action => 'index'
    assert_routing '/dvds/index/1', :controller => 'dvds', :action => 'index', :id => '1'
    assert true
  end

  def test_list_dvds
    facebook_get :index, :id => 2
    assert_response :success
    assert_template 'index'

    # see http://api.rubyonrails.org/classes/ActionController/TestCase.html
    assert_not_nil dvds(:house)
    assert_not_nil assigns(:dvds)
    @dvd = assigns(:dvds)[0]
    puts " upc of dvd house is: " + @dvd.title
  end

  def test_show_one_dvd
    facebook_get :show, :id => 1
    assert_response :success
    assert_template 'show'
  end
  
end
