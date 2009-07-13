require 'test_helper'
require 'json/ext'
require 'lib/iso/isolookup'

class Iso_Lookup_Test < ActiveSupport::TestCase
  # Replace this with your real tests.

  def setup
    @iso = Iso_Lookup.new
  end

  def teardown
    @iso = nil
  end
  
  def test_getTorrents
    jcontent = @iso.getTorrents("Alvin and the chipmunks", 'Video/Movies')
    assert jcontent
  end

end

