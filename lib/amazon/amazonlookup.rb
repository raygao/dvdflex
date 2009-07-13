class Amazon_Helper
  require 'amazon/aws'
  require 'amazon/aws/search'
  require 'dvd'
  require 'country'
  require 'cgi'
  require 'uri'

  include Amazon::AWS
  include Amazon::AWS::Search

  #KEY_ID = '1D5H84BYKDE3XKW4QSR2'
  #ASSOCIATES_ID = 'dvdflare4us-20'

  def logger
    RAILS_DEFAULT_LOGGER
  end

  def stripe_ending (title)
    logger.info("Old title: " + title.to_s)
    trimoff_pos = title.index(/[\[\(\{]/) ? title.index(/[\[\(\{]/) : 0
    if (trimoff_pos > 1)
      cleaned_title = title[0, trimoff_pos - 1]
      return cleaned_title
    else
      return title
    end
  end

  def find_dvd_in_amazon_by_upcode (upcode, locale)

    logger.info  "*****started find_dvd_in_amazon_by_upcode*******"
    #original api doc http://www.awszone.com/scratchpads/aws/ecs.us/ItemLookup.aws
    #example
    #itemlookup = ItemLookup.new( 'UPC', { 'ItemId' => '043396239494', 'SearchIndex' => 'DVD' } )
    begin
      itemlookup = ItemLookup.new( 'UPC', { 'ItemId' => upcode, 'SearchIndex' => 'DVD' } )

      request = Request.new(KEY_ID, ASSOCIATES_ID)
      if locale.nil?
        request.locale = LOCALE
      else
        request.locale = locale
      end

      if SECRET_KEY_ID
        request.config['secret_key_id'] = SECRET_KEY_ID
      end

      rg = ResponseGroup.new( 'Medium' )

      #do search with Amazon associate web services
      response = request.search( itemlookup, rg )

      unless response.nil? #found a DVD matching UPC code in Amazon
        item_set = response.item_lookup_response[0].items[0]

        item_attributes = item_set.item[0].item_attributes[0]

        #required section - Title, UPC, PageURL always exists
        title = item_attributes.title[0].to_s
        logger.info "title is: " + title

        title = stripe_ending(title)
        logger.info "Title is: #{title}"

        pageurl = item_set.item[0].detail_page_url[0].to_s

        cc = Country.find_by_code(request.locale)
        country = cc.id

        #optional details
        #looking images from amazon
        if !item_set.item[0].medium_image.nil?
          medium_image = item_set.item[0].medium_image[0].url[0].to_s
        else
          medium_image = 'http://g-ecx.images-amazon.com/images/G/01/nav2/dp/no-image-avail-img-map._V46862177_AA192_.gif'
        end

        if !item_set.item[0].small_image.nil?
          small_image = item_set.item[0].small_image[0].url[0].to_s
        else
          small_image = 'http://g-ecx.images-amazon.com/images/G/01/x-site/icons/no-img-sm._V47056216_.gif'
        end

        if !((item_attributes.running_time.nil?) || (item_attributes.running_time[0].nil?))
          running_time = item_attributes.running_time[0]
          logger.info "Running Time is: #{running_time}"
        else
          running_time = nil
        end


        if !((item_attributes.release_date.nil?) || (item_attributes.release_date[0].nil?))
          dvd_release_date = item_attributes.release_date[0].to_s
          logger.info "Release Date is:#{dvd_release_date}"
        else
          dvd_release_date = nil
        end


        if !((item_attributes.theatrical_release_date.nil?) || (item_attributes.theatrical_release_date[0].nil?))
          theatrical_release_date = item_attributes.theatrical_release_date[0].to_s
          logger.info "Theatrical Release Date is:#{theatrical_release_date}"
        else
          theatrical_release_date = nil
        end

        
        if !((item_attributes.original_release_date.nil?) || (item_attributes.original_release_date[0].nil?))
          original_release_date = item_attributes.original_release_date[0].to_s
          logger.info "Original Release Date is:#{original_release_date}"
        else
          original_release_date = nil
        end

        #extra info
        description = nil
        if !((item_set.item[0].editorial_reviews.nil?) || (item_set.item[0].editorial_reviews[0].editorial_review.nil?))
          reviews = item_set.item[0].editorial_reviews[0].editorial_review
          if (!reviews.nil?)
            reviews.each do |review|
              #if ((review.source[0] == "Description") || (review.source[0] == "Product Description"))
              if (review.source[0].to_s.upcase.index("DESCRIPTION"))
                description = review.content[0].to_s
                logger.info "****Product Description: #{description}"
                break
              else
                logger.info "****Other - (#{review.source[0]}): #{review.content[0]}"
                break
              end
            end
          end
        end

        if (!item_attributes.region_code.nil?)
          region_code = item_attributes.region_code[0].to_i
        else
          region_code = nil
        end

        if (!item_attributes.director.nil?)
          director = item_attributes.director[0].to_s
        else
          director = nil
        end

        if (!item_attributes.actor.nil?)
          actors_array = item_attributes.actor
          actors = ""
          if (!actors_array.nil?)
            actors_array.each do |actor|
              actors << actor.to_s + ", "
              logger.info actor.to_s + ", "
            end
          end
        end


# example
    @dvd = Dvd.new(:upc => '2423', :title => 'title',
      :medium_image => 'medium_image', :small_image => 'small_image',
      :pageurl => 'pageurl', :country_id => 55, :description => 'description',
      :running_time => 453, :theatrical_release_date => 'theatrical_release_date',
      :dvd_release_date => 'dvd_release_date', :region_code => 'region_code',
      :director => 'director', :actors => 'actors')


        logger.info  "*******before calling vod*******"
        vod = nil
        #Amazon (Unbox / VideoOnDemand) has been enabled.
        #vod = find_vod_in_amazon_with_title(title, director)? find_vod_in_amazon_with_title(title, director) : nil
        vod = find_vod_in_amazon_with_title(title, original_release_date, director)? find_vod_in_amazon_with_title(title, original_release_date, director) : nil

        @dvd = Dvd.new(:upc => upcode, :title => title, :medium_image => medium_image,
          :small_image => small_image, :pageurl => pageurl, :country_id => country,
          :description => description, :running_time => running_time,
          :theatrical_release_date => theatrical_release_date, :dvd_release_date => dvd_release_date,
          :region_code => region_code, :director => director, :actors => actors,
          :vod => vod)
        
        return @dvd

      else #not found in Amazon Associate Web Services
        return nil
      end
    rescue Amazon::AWS::Error::InvalidParameterValue => ame
      #flash[:error] = ame.lineno + "#{ame.message}"
      puts "******Error******: " + " #{ame.message}"
      logger.info "******Error******: " + " #{ame.message}"
      return nil
    rescue Error => ee
      #flash[:error] = ame.lineno + "#{ame.message}"
      puts "******Error******: " + " #{ee.message}"
      logger.info "******Error******: " + " #{ee.message}"
      return nil
    rescue Exception => ex
      #flash[:error] = ame.lineno + "#{ame.message}"
      puts "******Error******: " + " #{ex.message}"
      logger.info "******Error******: " + " #{ex.message}"
      return nil
    end


  end

  # parameters,
  # title - dvd title
  # release - Date of the Movie release
  # dvd_director - Director of the movie
  # it is know that Amazon provides conflicting information between DVD and
  # VOD, for example "The Mask of Zorro". Therefore, some movies are skipped over.
  def find_vod_in_amazon_with_title (title, t_release_date, dvd_director)
    #def find_vod_in_amazon_with_title (title, dvd_director)
    # example URL
    # http://ecs.amazonaws.com/onca/xml?Service=AWSECommerceService&Version=2005-03-23&Operation=ItemSearch&SubscriptionId=1D5H84BYKDE3XKW4QSR2&AssociateTag=dvdflare4us-20&SearchIndex=UnboxVideo&ResponseGroup=Medium&Title=Quantum-of-Solace
    #example
    begin
      logger.info  "******* Calling vod *******"
      ######## for Ruby-AAWS 0.7###########
      # Changing space character into '+' signs, only for NetBeans bug
      # it affects the amazon.rb file
      # line 29,     string.gsub( /([^\+\%a-zA-Z0-9_.~-]+)/ ) do
      t1 = CGI::unescape(title)
      t1 = t1.gsub(/[@:!$%^&*()#.]/, '') # Stripping illegal characters"
      t1 = t1.gsub(/\'/, '')
      t1 = t1.gsub(/\//, '')
      t1 = t1.gsub(/\,/, '')
      t1 = t1.gsub(/\-/, '')
      t1 = t1.gsub(/\~/, '')
      t1 = t1.gsub(/\;/, '')
      title_safe_escaped = CGI::escape(t1) 
      
      title_safe_escaped = t1 # for regular ruby on command line

      itemsearch = ItemSearch.new('UnboxVideo' , {'Title' => title_safe_escaped})
      #itemsearch = ItemSearch.new('UnboxVideo' , {'Title' => title})
      ########## end Ruby-AAWs 0.7#########################

      #itemsearch = ItemSearch.new('UnboxVideo' , {'Title' => title}) # for Ruby-AAWS 0.4.4
      #itemsearch = ItemSearch.new('Books',       {'Title' => 'ruby programming' } )

      request = Request.new(KEY_ID, ASSOCIATES_ID)
      # only available in USA
      request.locale = 'us'

      if SECRET_KEY_ID
        request.config['secret_key_id'] = SECRET_KEY_ID
      end

      request.config['encoding'] = 'iso-8859-15'

      rg = ResponseGroup.new( 'Medium' )

      logger.info "******* before vod search *******"
      #do search with Amazon associate web services
      response = request.search( itemsearch, rg )
      logger.info  "******* after vod search *******"

      unless response.nil? #found a DVD matching UPC code in Amazon
        items = response.item_search_response[0].items[0].item
        items.each do |item_set|
          #item_set = response.item_search_response[0].items[0]
          item_attributes = item_set.item_attributes[0]

          #required section - Title, UPC, PageURL always exists
          title = item_attributes.title[0].to_s

          title = stripe_ending(title)
          logger.info "Title of the VOD is: #{title}"

          vodurl = item_set.detail_page_url[0].to_s
          #price = item_set.item[0].offer_summary[0].lowest_price[0].amount[0]

          # Check to see if it is a movie remake or movie/series with similar name.
          # Remake will have a different director.
          # such as "House of Wax" is a remake.
          if (!item_attributes.director.nil?)
            director = item_attributes.director[0].to_s
          end

          # If either Director or Release date match, it is good,
          # Amazon provides conflicting information,
          # for Example, The Mask of Zorro is off by a date 16 vs. 17 for
          # the Theatrical Release Date

          if !((item_attributes.theatrical_release_date.nil?) || (item_attributes.theatrical_release_date[0].nil?))
            theatrical_release_date = item_attributes.theatrical_release_date[0].to_s
            logger.info "Release Date is:#{theatrical_release_date}"
          end

        logger.info  "*******before returning vod*******"

          if (theatrical_release_date == t_release_date)
            return vodurl
          end

          if (director == dvd_director)
            return vodurl
          end

        end
        # no suitable match found. all movies have wrong director
        return nil

        #optional details
        #looking images from amazon

      else #not found in Amazon Associate Web Services
        logger.info "No matching VOD found in Amazon Unbox."
        return nil
      end
    rescue Amazon::AWS::Error::AWSError  => e
      if e.message == "We did not find any matches for your request."
        logger.info "(VOD warning) Cannot find a suitable VOD for your DVD, amazon message: " + e.message
      else
        logger.info "(VOD warning) Other types of search error for VOD search, amazon message: " + e.message
      end
      puts "error: " + e.message
      return nil
    rescue Amazon::AWS::Error::InvalidParameterValue => ame
      #flash[:error] = ame.lineno + "#{ame.message}"
      puts "Error in 'find_vod_in_amazon_with_title (title)': " + " #{ame.message}"
      logger.info "Error in 'find_vod_in_amazon_with_title (title)': " + " #{ame.message}"
      return nil
    rescue Error => oe
      #flash[:error] = ame.lineno + "#{ame.message}"
      puts "Error in 'find_vod_in_amazon_with_title (title)': " + " #{oe.message}"
      logger.info "Error in 'find_vod_in_amazon_with_title (title)': " + " #{oe.message}"
      return nil
    rescue Exception => ex
      #flash[:error] = ame.lineno + "#{ame.message}"
      puts "Error in 'find_vod_in_amazon_with_title (title)': " + " #{ex.message}"
      logger.info "Error in 'find_vod_in_amazon_with_title (title)': " + " #{ex.message}"
      return nil
    rescue NameError => ne
      #flash[:error] = ame.lineno + "#{ame.message}"
      puts "Error in 'find_vod_in_amazon_with_title (title)': " + " #{ne.message}"
      logger.info "Error in 'find_vod_in_amazon_with_title (title)': " + " #{ne.message}"
      return nil
    end
  end


  # this method is used only by the DVD/Search.fbml page.
  # returns an array of all the possible matching VODs
  def search_vod_in_amazon_by_title (title)
    #def find_vod_in_amazon_with_title (title, dvd_director)
    # example URL
    # http://ecs.amazonaws.com/onca/xml?Service=AWSECommerceService&Version=2005-03-23&Operation=ItemSearch&SubscriptionId=1D5H84BYKDE3XKW4QSR2&AssociateTag=dvdflare4us-20&SearchIndex=UnboxVideo&ResponseGroup=Medium&Title=Quantum-of-Solace
    #example
    begin
      ######## for Ruby-AAWS 0.7###########
      # Changing space character into '+' signs
      t1 = CGI::unescape(title)
      t1 = t1.gsub(/[@:!$%^&*()#.]/, '') # Stripping illegal characters"
      t1 = t1.gsub(/\'/, '')
      t1 = t1.gsub(/\//, '')
      t1 = t1.gsub(/\,/, '')
      t1 = t1.gsub(/\-/, '')
      t1 = t1.gsub(/\~/, '')
      t1 = t1.gsub(/\;/, '')
      title_safe_escaped = CGI::escape(t1) 

      itemsearch = ItemSearch.new('UnboxVideo' , {'Title' => title_safe_escaped})
      #for regular ruby 1.8.7
      #itemsearch = ItemSearch.new('UnboxVideo' , {'Title' => title})
      ########## end Ruby-AAWs 0.7#########################

      #itemsearch = ItemSearch.new('UnboxVideo' , {'Title' => title}) # for Ruby-AAWS 0.4.4
      #itemsearch = ItemSearch.new('Books',       {'Title' => 'ruby programming' } )


      request = Request.new(KEY_ID, ASSOCIATES_ID)
      # only available in USA
      request.locale = 'us'

      rg = ResponseGroup.new( 'Medium' )

      #do search with Amazon associate web services
      response = request.search( itemsearch, rg )

      unless response.nil? #found a DVD matching UPC code in Amazon
        vods = Array.new
        items = response.item_search_response[0].items[0].item
        items.each do |item_set|
          #item_set = response.item_search_response[0].items[0]
          item_attributes = item_set.item_attributes[0]

          #required section - Title, UPC, PageURL always exists
          title = item_attributes.title[0].to_s

          title = stripe_ending(title)
          logger.info "Title of the VOD is: #{title}"

          vodurl = item_set.detail_page_url[0].to_s

          #optional details
          #looking images from amazon
          if !item_set.medium_image.nil?
            medium_image = item_set.medium_image[0].url[0].to_s
          else
            medium_image = 'http://g-ecx.images-amazon.com/images/G/01/nav2/dp/no-image-avail-img-map._V46862177_AA192_.gif'
          end

          if !item_set.small_image.nil?
            small_image = item_set.small_image[0].url[0].to_s
          else
            small_image = 'http://g-ecx.images-amazon.com/images/G/01/x-site/icons/no-img-sm._V47056216_.gif'
          end

          if !((item_attributes.running_time.nil?) || (item_attributes.running_time[0].nil?))
            running_time = item_attributes.running_time[0]
            logger.info "Running Time is: #{running_time}"
          end


          if !((item_attributes.release_date.nil?) || (item_attributes.release_date[0].nil?))
            dvd_release_date = item_attributes.release_date[0].to_s
            logger.info "Release Date is:#{dvd_release_date}"
          end

          if !((item_attributes.theatrical_release_date.nil?) || (item_attributes.theatrical_release_date[0].nil?))
            theatrical_release_date = item_attributes.theatrical_release_date[0].to_s
            logger.info "Theatrical Release Date is:#{theatrical_release_date}"
          end

          if (!item_attributes.director.nil?)
            director = item_attributes.director[0].to_s
          end

          if (!item_set.offer_summary[0].lowest_new_price.nil?)
            price = item_set.offer_summary[0].lowest_new_price[0].formatted_price[0]
          end

          vod = VOD.new(title, vodurl, medium_image, small_image, running_time, dvd_release_date, director, price)
          vods << vod
        end
        return vods

      else #not found in Amazon Associate Web Services
        logger.info "No matching VOD found in Amazon Unbox."
        return nil
      end
    rescue Amazon::AWS::Error::AWSError  => e
      if e.message == "We did not find any matches for your request."
        logger.info "(VOD warning) Cannot find a suitable VOD for your DVD, amazon message: " + e.message
      else
        logger.info "(VOD warning) Other types of search error for VOD search, amazon message: " + e.message
      end
      puts "error: " + e.message
      return nil
    rescue Amazon::AWS::Error => ame
      #flash[:error] = ame.lineno + "#{ame.message}"
      puts "Error in 'find_vod_in_amazon_with_title (title)': " + " #{ame.message}"
      logger.info "Error in 'find_vod_in_amazon_with_title (title)': " + " #{ame.message}"
      return nil
    rescue Error => oe
      #flash[:error] = ame.lineno + "#{ame.message}"
      puts "Error in 'find_vod_in_amazon_with_title (title)': " + " #{oe.message}"
      logger.info "Error in 'find_vod_in_amazon_with_title (title)': " + " #{oe.message}"
      return nil
    rescue Exception => ex
      #flash[:error] = ame.lineno + "#{ame.message}"
      puts "Error in 'find_vod_in_amazon_with_title (title)': " + " #{ex.message}"
      logger.info "Error in 'find_vod_in_amazon_with_title (title)': " + " #{ex.message}"
      return nil
    rescue NameError => ne
      #flash[:error] = ame.lineno + "#{ame.message}"
      puts "Error in 'find_vod_in_amazon_with_title (title)': " + " #{ne.message}"
      logger.info "Error in 'find_vod_in_amazon_with_title (title)': " + " #{ne.message}"
      return nil
    end
  end

end


class VOD
  def title
    return @title
  end

  def vodurl
    return @vodurl
  end

  def medium_image
    return @medium_image
  end

  def small_image
    return @small_image
  end

  def running_time
    return @running_time
  end

  def dvd_release_date
    return @dvd_release_date
  end

  def director
    return @director
  end

  def lowest_price
    return @lowest_price
  end

	def initialize (title, vodurl, medium_image, small_image, running_time, dvd_release_date, director, lowest_price)
		@title = title
    @vodurl = vodurl
    @medium_image = medium_image
    @small_image = small_image
    @running_time = running_time
    @dvd_release_date = dvd_release_date
    @director = director
    @lowest_price = lowest_price
	end
end