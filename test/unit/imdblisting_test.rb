$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'test_helper'
require 'lib/amazon/amazonlookup'
require 'lib/imdb/imdblookup'
require 'imdblisting'


class ImdbListingTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  logger = RAILS_DEFAULT_LOGGER

  def setup
    @amazon_helper = Amazon_Helper.new
    @locale = 'us'
    @imdb_helper = Imdb_Helper.new
  end

  def teardown
    @amazon_helper = nil
  end

  def test_find_imdb
    upcode = "043396239494" # Dance with Me
    upcode = "056775036591" # HomeTown Story/Marilyn Monroe
    country ='us'
    @dvd = @amazon_helper.find_dvd_in_amazon_by_upcode(upcode, country)
    @title = @dvd.title
    @theatrical_release_date = @dvd.theatrical_release_date
    if (!@theatrical_release_date.nil?)
      date = @theatrical_release_date[0..(@theatrical_release_date.index("-")-1)]
    else
      date = 0
    end

    results = @imdb_helper.search_movie_by_title(@title + " (#{date})")
    assert_not_nil results
    @imdb_helper.console_display_movies_details(results, 5)

    if (!results.nil?)
      @imdb_helper.console_display_movies_details(results, 5)
      movie = results[0]

      imdblisting = Imdblisting.new
      imdblisting.dvd_id = @dvd.id
      imdblisting.imdb_id = movie.id
      imdblisting.title = movie.title
      imdblisting.year = movie.year
      imdblisting.rating = movie.rating
      imdblisting.length = movie.length
      imdblisting.director = movie.director
      imdblisting.actors = movie.cast_members[0..4].join(", ")
      imdblisting.genre = movie.genres.join(", ")
      imdblisting.plot = movie.plot
      imdblisting.url = "http://www.imdb.com/title/tt#{movie.id}/"

      v = imdblisting.valid?
      puts "valid: #{v}"
      assert v
      assert imdblisting.save()
    end
  end
end