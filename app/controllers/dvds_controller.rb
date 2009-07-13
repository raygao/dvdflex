class DvdsController < ApplicationController

  require RAILS_ROOT + '/lib/amazon/amazonlookup'
  require RAILS_ROOT + '/lib/iso/isolookup'
  #require RAILS_ROOT + '/lib/imdb/imdblookup'

  def index
    # find all dvd listings, not working at this moment
    @dvds = Dvd.find(:all)
  end

  def show
    # show a specific dvd with dvd listing id.
    id = params[:id]
    #render :text => "ID of the DVD is #{id}"
    @dvd = Dvd.find(id)
    @listings = Listing.find_all_by_dvd_id(@dvd.id.to_s)
  end

  def new
    # see create function below for creating a new dvd listing
    @dvd = Dvd.new
    @countries = Country.find(:all)
  end

  def search
    # see create function below for creating a new dvd listing
    @dvd = Dvd.new
    if !(params[:dvd].nil?)
      title = params[:dvd][:title]
      @results =Dvd.find(:all, :conditions=> ["title like :search", {:search => "%" +  title + "%"}])
      size = @results.size
      if (@results.size < 1)
        flash[:notice] = "None was found, please try again"
      end
      logger.debug "Found #{size} DVDs matching #{title} in the local database"

      if (params[:amazon] == "on")
        @amazon_helper = Amazon_Helper.new
        @amazon_vods = @amazon_helper.search_vod_in_amazon_by_title(title)
      else
        @amazon_vods = nil
      end
    end
  end

  def preprocess
    # find a dvd listing that matches the specified upc code.
    upcode = params[:dvd][:upc]
    country = params[:dvd][:country_id]
    #   render :text => "UPC code is #{upcode}"
    #=begin
    if (upcode.nil? || upcode.to_s.nil? || upcode.to_s.size <= 0)
      # check for UPC code is not zero string
      flash[:notice] = 'UPC code cannot be empty.'
      redirect_to new_dvd_path
      return
    end

    @dvd = Dvd.find_by_upc(upcode) #local in local database first

    if @dvd.nil?
      # not in the local database, look remote in Amazon ECS
      # preprocess via Amazon ECS services using this UPC code

      amazon_helper = Amazon_Helper.new
      @dvd = amazon_helper.find_dvd_in_amazon_by_upcode(upcode, country)

      if !@dvd.nil?
        # Save DVD in the local database
        @dvd.save

        # Save associated Torrents in the database
        isohelper = Iso_Lookup.new
        torrents = isohelper.getTorrents(@dvd.title, 'Video/Movies')
        torrents.each do |t|
          t['dvd_id'] = @dvd.id
          @torrent = Torrent.new(t)
          if @torrent.save
            puts "a torrent has been saved"
          else
            puts 'this torrent cannot be saved'
          end
        end

        # Get and save IMDB listing, not used due to error
        #doIMDB(@dvd)

        flash[:notice] = "Do you want to add the following DVD to your libaray?"
      else
        flash[:error] = "Cannot find a DVD with matching UPC code. \
            Please make sure that  you have selected the correct country and try it again."
        redirect_to new_dvd_path
      end

    else
      flash[:notice] = "Which one of the following DVD(s) do you want to add to your libaray?"
    end
    #=end
  end

  # not used at this moment
  def doIMDB(dvd)
    imdb_helper = Imdb_Helper.new
    theatrical_release_date = dvd.theatrical_release_date
    date = theatrical_release_date[0..(theatrical_release_date.index("-")-1)]
    if (!@theatrical_release_date.nil?)
      date = @theatrical_release_date[0..(@theatrical_release_date.index("-")-1)]
    else
      date = 0
    end
    results = imdb_helper.search_movie_by_title(dvd.title + " (#{date})")
    if (!results.nil?)
      imdb_helper.console_display_movies_details(results, 5)
      movie = results[0]

      imdblisting = Imdblisting.new
      imdblisting.dvd_id = dvd.id
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

      imdblisting.save()

      return imdblisting
    else
      return nil
    end
  end

  def delete
    # remove the dvd listing from the db, need to remove the listings as well, either remove or delete.
  end

  def regenerate
    # if blank param, it regenerates all entries in the Database, which can be a
    # really long process.

    #it is better to regenerate a single DVD entry, using its UPC code.
    flash[:notice] = 'Regenerating all DVD listings, please waiting.'

    if !params[:upc].nil?
      # regenerate only one entry, e.g.
      # http://apps.facebook.com/dvdflex/dvds/regenerate?upc=7321925000870
      #@dvd = Dvd.find_by_upc(params[:upc])
      @dvd = Dvd.find_by_upc(params[:upc].to_s)
      @dvds = Array.new
      @dvds << @dvd
=begin
      locale = (Country.find(@dvd.country_id)).code

      amazon_helper = Amazon_Helper.new
      @dvd_updated = amazon_helper.find_dvd_in_amazon_by_upcode(@dvd.upc, locale)
      new_dvd_attrs = @dvd_updated.attributes

      if @dvd.update_attributes(new_dvd_attrs)
        render :text => "'#{@dvd_updated.title}' has been successfully regenerated in the DB."
        flash[:notice] = 'Listing was successfully updated.'
        #redirect_to listings_path
      else
        render :text => "failed to update"
        flash[:notice] = 'update error, please try again.'
        #redirect_to :action => :update
      end
=end
    else
      #otherwise, regenerate all entries.
      # with signed .amazonrc, it overloades the systema and causes error.
      # this batch processing, should not be allowed.
      @dvds = Dvd.find(:all)
    end
  end

end
