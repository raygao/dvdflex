# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'test_helper'
require 'lib/amazon/amazonlookup'

#logger = RAILS_DEFAULT_LOGGER

class Amazon_Lookup_Test < Test::Unit::TestCase


  def setup
    @amazon_helper = Amazon_Helper.new
    @locale = 'us'
  end

  def teardown
    @amazon_helper = nil
  end

  def test_find_amazon_item_util

    #need to create the country database, otherwise, it will fail.
    
    upcode = "043396216990" # The Mask of Zorro
    country ='us'
    @dvd = @amazon_helper.find_dvd_in_amazon_by_upcode(upcode, country)
    assert_not_nil @dvd.save, "DVD obtained from Amazon Associate Web Services should not be nil."
  end

  def test_find_amazon_unbox
    #title = 'Quantum-of-Solace'
    title ="The Matrix Revolutions"
    pageurl = @amazon_helper.find_vod_in_amazon_with_title(title, "2003-11-05", "Andy Wachowski")
    puts "URL is: " + pageurl
    assert_not_nil pageurl
  end

    def test_find_vod_from_dvd_search_page
      #title = 'Quantum-of-Solace'
      title ="The Mask of Zorro"
      vods = @amazon_helper.search_vod_in_amazon_by_title(title)
      #puts "URL is: " + url
      assert_not_nil vods
  end
  
end
