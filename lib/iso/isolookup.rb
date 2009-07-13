class Iso_Lookup
  require 'json'
  require 'json/ext'
  require 'rubygems'
  require 'httparty'

  def logger
    RAILS_DEFAULT_LOGGER
  end

  def generateit
    # see http://json.rubyforge.org/
    logger.info [ JSON.parser, JSON.generator ]
    #json = JSON.generate ({"pi"=>3.141})
    fruits = {:apple => "mansana", :orange=>"naranja"}
    geometry = {"pi"=>3.141}
    shopping = [fruits, geometry]
    json = JSON.generate(shopping)
    #([apple => "mansana", orange => "naranja"], {"pi"=>3.141})
    logger.info json
    return json
  end

  def parseit
    # see http://json.rubyforge.org/
    logger.info [ JSON.parser, JSON.generator ]
    #json = JSON.generate ({"pi"=>3.141})
    instring = '[{"apple":"mansana","orange":"naranja"},{"pi":3.141}]'
    json = JSON.parse(instring)
    #([apple => "mansana", orange => "naranja"], {"pi"=>3.141})
    logger.info "**parsed json is" + json.to_s
    return json
  end

  def getTorrents(query, type)
    begin
      content = ISOHunter.find_by_name_in_isohunter(query)
      if ((content['items'].nil?) || (content['total_results'] < 1))
        logger.info "No suitable torrent file was found."
        return nil
      end
      logger.info "Description: " + content["description"]

      torrents = Array.new
      i = 0

      jcontent = content['items']['list']

      logger.info "Found " + content['items']['list'].size.to_s + "  matching."
      jcontent.each do |each|
        logger.info "*" * 80

        torrent = Hash.new
        # link points to the detail page on ISOHunter
        # url points to the actual .torrent file
      
        torrent['torrent'] = each['enclosure_url']
        torrent['category'] = each['category']
        torrent['link'] = each['link']
        torrent['size'] = each['size']
        torrent['pubdate'] = each['pubDate']

        logger.info "Torrent URL: " + torrent['torrent']
        logger.info "Detailed page: "  + torrent['link']
        logger.info "Size: " + torrent['size']
        logger.info "Category: " + torrent['category']
        logger.info 'pubDate: ' + torrent['pubdate']

        if (torrent['category'] == type)

          torrents[i] = torrent
          i = i + 1
          logger.info "****added #{i}th row ****"
        else
          logger.info '***skipping***'
        end
      end
      if torrents.size > 0
        puts "***returning #{torrents.size} torrents***"
        return torrents
      else
        return nil
      end
    rescue Error => err
      logger.info "An Error occurred in the isolookup.rb file: " + err.message
      return nil
    rescue Exception => ex
      logger.info "An Exception occurred in the isolookup.rb file: " + ex.message
      return nil

    end

  end

end

class ISOHunter
  include HTTParty
  base_uri 'isohunt.com/js/json.php'
  default_params :output => 'json'
  format :json

  def self.find_by_name_in_isohunter(search_term)
    #get('/js/json.php?ihq=ubuntu&start=21&rows=20&sort=seeds', :query => {:other => other})
    maxrows = MAX_ISO_SEARCH_NUMBER ? MAX_ISO_SEARCH_NUMBER: 10
    get('/js/json.php', :query => {:ihq => search_term, :start => '1', :rows => maxrows, :sort => 'relevance'})
  end
end