require 'excel'

class UtilsController < ApplicationController
  def invite
    @from_user_id = facebook_session.user.to_s
    # show invite.fbml.erb page
  end

  def should_update_profile?
    @from = params[:from]
  end

  def update_profile
  	@user = facebook_session.user
    # TODO print to my profile using publisher.

  end

  def confirmed
    @sent_to_ids = params[:ids]
    if (@sent_to_ids.nil?)
      # if clicked the skip button, this will redirect back to the index/listings page.
      redirect_to listings_url
    end
    # If invitation has been successfully sent, show the Confirmation page.
  end

  def welcome
    UserPublisher.deliver_profile_update(current_user)
    # Welcome page for new user, display info in the profile
    # Are these being used?
    if should_update_profile?
  	  update_profile
  	end
    # show DVDflex's main page.
    redirect_to listings_url
  end

  def export
    @text = "exporting your DVD list as a CSV file."
    #send_file '/Users/raygao2000/Desktop/iLike.dmg',  :disposition => 'attachment'
    ##TODO not working as of yet.
    @export_base = 'http://' + request.env["HTTP_HOST"] + request.env['PATH_INFO']
    # TO create export and download function,
    @uid = current_user.id
    user = User.find(@uid)
    listings = user.listings
    if listings.size > 0
      @export_url =  'http://' + request.env["HTTP_HOST"] + '/utils/doexport' + "?uid=#{@uid}"
      "http://web1.tunnlr.com:10337/utils/doexport" + "?uid=#{@uid}"
      logger.info @export_url
    else
      # In case the user has no listing, the export button will be disabled.
      @export_url = nil
    end
    # use :canvas => false to bypass Facebook.
    # http://forums.pragprog.com/forums/59/topics/2860
    #redirect :action => index
    # <fb:redirect url="http://apps.facebook.com/myapp/?not_in_group" />
  end

  def doexport
    @text = "exporting your DVD list as a CSV file."
    @uid = params[:uid]
    generate_file(@uid)
  end

  #fixed the doexport route issue.
  def generate_file (uid)
    user = User.find(uid)
    listings = user.listings

    if listings.size > 0

      e = Excel::Workbook.new
      array = Array.new
      for listing in listings
        item = Hash.new
        item["listing_id"] = listing.id
        item["dvd_id"] = listing.dvd_id
        item["your note"] = listing.note
        item["upc"] = listing.dvd.upc
        item["title"] = listing.dvd.title
        item["description"] = listing.dvd.description
        item["running_time"] = listing.dvd.running_time
        item["theatrical_release_date"] = listing.dvd.theatrical_release_date
        item["director"] = listing.dvd.director
        item["actors"] = listing.dvd.actors
        item["add_to_library_on"] = listing.created_at
        item["medium_image"] = listing.dvd.medium_image
        item['pageurl'] = listing.dvd.pageurl
        item["video_on_demand_url"] = listing.dvd.vod

        # URL TO IMDB is not kept in the database. Rather, it is constructed dynamically.
        if (!listing.dvd.theatrical_release_date.nil?)
          d = listing.dvd.theatrical_release_date.split("-")
          date = d[0]
          item['imdb'] = "http://www.imdb.com/find?s=tt&q=#{listing.dvd.title} (#{date})"
        else
          item['imdb'] = ""
        end

        array << item
      end
      e.addWorksheetFromArrayOfHashes("Your DVD Listing", array)
      # send back the listing export file to the end user
      headers['Content-Type'] = "application/vnd.ms-excel"
      render :text => e.build
    else
      flash[:notice] = "You don't have any listings to export."
      redirect_to listings_url
    end
  end
end
