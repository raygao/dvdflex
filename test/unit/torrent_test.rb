require 'test_helper'
require 'test/unit'
require 'lib/amazon/amazonlookup'
require 'amazon/aws'
require 'amazon/aws/search'
require 'dvd'
require 'country'
require 'torrent'
require 'json/ext'
require 'lib/iso/isolookup'

class TorrentTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def setup
    @amazon_helper = Amazon_Helper.new
    @iso = Iso_Lookup.new
    @locale = 'us'
  end

  def test_addTorrent
    upcode = "024543503019"
    country ='us'
    @dvd = @amazon_helper.find_dvd_in_amazon_by_upcode(upcode, country)
    assert_not_nil @dvd.save, "DVD obtained from Amazon Associate Web Services should not be nil."

    torrents = @iso.getTorrents(@dvd.title, 'Video/Movies')
    assert torrents

    torrents.each do |torrent|
      puts torrent['url']
      torrent['dvd_id'] = @dvd.id
      t = Torrent.new(torrent)
    end

  end


end
