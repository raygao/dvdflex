class TorrentsController < ApplicationController
  # GET /torrents
  # GET /torrents.xml
  def index
    if (params[:id].nil?)
      @torrents = Torrent.find(:all)
    else
      @torrents = Torrent.find_all_by_dvd_id(params[:id])
    end
  end

  def show_dvd
    #render :text => "in show dvd routes"
    @dvd_id = params[:id]
    @torrents = Torrent.find_all_by_dvd_id(@dvd_id)
  end
  # GET /torrents/1
  # GET /torrents/1.xml
  def show
    @torrent = Torrent.find(params[:id])
  end

  # GET /torrents/new
  # GET /torrents/new.xml
  def add
    @torrent = Torrent.new
    @torrent.dvd_id = params[:id]
  end

  # GET /torrents/1/edit
  def edit
    @torrent = Torrent.find(params[:id])
  end

  # POST /torrents
  # POST /torrents.xml
  def create
    @torrent = Torrent.new(params[:torrent])

      if @torrent.save
        flash[:notice] = 'Torrent was successfully created.'
        render :text => flash[:notice]
        #format.fbml { redirect_to(@torrent) }
        #format.html { redirect_to(@torrent) }
        #format.xml  { render :xml => @torrent, :status => :created, :location => @torrent }
      else
        flash[:notice] = 'Torrent could not be created.'
        render :text => flash[:notice]
        #format.html { render :action => "new" }
        #format.xml  { render :xml => @torrent.errors, :status => :unprocessable_entity }
    end
  end

  # PUT /torrents/1
  # PUT /torrents/1.xml
  def update
    @torrent = Torrent.find(params[:id])

      if @torrent.update_attributes(params[:torrent])
        flash[:notice] = 'Torrent was successfully updated.'
        format.html { redirect_to(@torrent) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @torrent.errors, :status => :unprocessable_entity }
      end
  end

  # DELETE /torrents/1
  # DELETE /torrents/1.xml
  def destroy
    @torrent = Torrent.find(params[:id])
    @torrent.destroy

      format.html { redirect_to(torrents_url) }
      format.xml  { head :ok }
  end
end
