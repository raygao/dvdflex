require 'test_helper'

class DvdTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  fixtures :dvds

  def test_invalid_with_empty_attributes
    dvd = Dvd.new
    # an empty dvd  model should be invalid
    assert !dvd.valid?
    # the upc field should have validation errors
    assert dvd.errors.invalid?(:upc)
    # the body field should have validation errors
    assert !dvd.save
  end

  def test_invalid_with_redundant_upcode
    dvd = Dvd.new(:upc => '085393894528', :title => 'House of Wax',
      :medium_image => 'http://ecx.images-amazon.com/images/I/51QH23D2VML._SL160_.jpg',
      :small_image => 'http://ecx.images-amazon.com/images/I/51imL8XXgLL._SL75_.jpg')
    assert(!dvd.save, 'dvd with duplicate UPC code cannot be saved.')
    assert dvd.errors.invalid?(:upc)

  end

  def test_add_valid_entry
    dvd = Dvd.new(:upc => '097368512146 ', :title => 'Go Diego Go! - Safari Rescue',
      :medium_image => 'http://ecx.images-amazon.com/images/I/61Y7GMybWbL._SL160_.jpg',
      :small_image => 'http://ecx.images-amazon.com/images/I/61Y7GMybWbL._SL75_.jpg')
    assert dvd.save
    assert true
  end

  def test_find_by_upc
    dvd = Dvd.find_all_by_upc('085393894528')
    assert dvd.size > 0

    dvd = Dvd.find_all_by_upc('invalid')
    assert dvd.size == 0
  end

  def test_find_by_title
    dvd = dvds(:house)
    assert dvd
  end
  
end