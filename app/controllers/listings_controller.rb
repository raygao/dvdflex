class ListingsController < ApplicationController
  def index
    
    if (!request.env['QUERY_STRING'].nil?)
      # This addresses the app login problem, previously it was directed to index.html.erb
      # previously, it was directed to http://web1.tunnlr.com:10337//?auth_token=9ab1b965ac6337d34dbb135927d54767
      # now, it gets redirect to http://apps.facebook.com/dvdflex

      case DVDFLEX_ENV
        when 'dev'
          redirect_to "http://apps.facebook.com/dvdflex_dev"
        when 'test'
          redirect_to "http://apps.facebook.com/dvdflex_test"
        when 'prod'
          redirect_to "http://apps.facebook.com/dvdflex"
      end

    end


    if params[:user_id]
      # find listings with userid
      @user = User.find(params[:user_id])
    else
      # find listings of the current user
      @user = current_user
      # classic way of finding friends
      @list_of_friends = (params[:fb_sig_friends]||"").split(/,/)
      # API way of finding friends. not working as of now
      # @list_of_friends = @user.facebook_session.user.friends
      @friends_listings = Listing.find_for_friends(@list_of_friends)
    end

    @listings = @user.listings #these are my listings

  end

  def show
    # show detail of an individual dvd listings
    # to do, need to fix the routing in index.fbml.erb
    @listing = Listing.find(params[:id])
  end

  def showuser
    # show dvd listings of a particular user with user id as input
    @user = User.find(params[:id])
    @listings = @user.listings
  end

  def new
    # creates a new dvd listing, in term calls the create function
    @listing = Listing.new
    @dvd_id = params[:dvd_id]
  end

  def create
    #render :text => 'current user is: ' + current_user.facebook_id.to_s
    @listing = Listing.new(params[:listing])
    @listing.dvd_id = params[:listing][:dvd_id]
    @listing.user_id = current_user.id #need user id
    #
    #=begin
    if @listing.save
      flash[:notice] = 'Your items has been entered into the system.'
      #UserPublisher.deliver_profile_update(current_user)
      UserPublisher.deliver_addlisting(@listing)
      redirect_to listings_path
    else
      flash[:notice] = 'There was an error in saving your item.' + @listing.errors.full_messages
      redirect_to new_listing_path
    end
    #=end
  end

  def edit
    # show the edit template, which calls the update function.
    @listing = Listing.find(params[:id])
  end

  def update
    # updates a listing
    #render :text => "update listing: " + params[:listing][:note]
    @listing = Listing.find(params[:id])

    if @listing.update_attributes(params[:listing])
      flash[:notice] = 'Listing was successfully updated.'
      redirect_to listings_path
    else
      flash[:notice] = 'update error, please try again.'
      redirect_to :action => :update
    end
  end

  def destroy
    # deletes a dvd listing
    @listing = Listing.find(params[:id])
    @dvd = Dvd.find(@listing.dvd_id)

    @listing.destroy
    flash[:notice] = "\"#{@dvd.title}\" has been deleted from your DVD library."
    redirect_to listings_path

  end

  def test_ajax
  end

end
