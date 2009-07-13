# Not used in the code, due to parsing error.
# as of June 23, 2009
class Imdb_Helper
  require 'hpricot'
  require 'open-uri'
  require 'imdb/movie'
  require 'imdb/search'
  require 'imdb/cli'
  require 'imdb'
  
  def logger
    RAILS_DEFAULT_LOGGER
  end

  def fetch_movie_by_imdb_id(imdb_id)
    puts ">> Fetching movie #{imdb_id}"
    # logger.info ">> Fetching movie #{imdb_id}"
    movie = Imdb::Movie.new(imdb_id)
    movies = Array.new
    movies << movie

    return movies
  end

  def search_movie_by_title(query)
    puts ">> Searching for \"#{query}\""
    # logger.info ">> Searching for \"#{query}\""
    search = Imdb::Search.new(query)
    movies = Array.new
    movies = search.movies
    # puts "Movies size is #{movies.size}"
    return movies
  end

  def console_display_individual_movie_details(movie)
    puts
    puts "#{movie.id}: #{movie.title} - (#{movie.year})"
    puts "=" * 72
    puts "Rating: #{movie.rating}"
    puts "Length: #{movie.length} minutes"
    puts "Directed by: #{movie.director.join(", ")}"
    puts "Actors: #{movie.cast_members[0..4].join(", ")}"
    puts "Genre: #{movie.genres.join(", ")}"
    puts "Plot: #{movie.plot}"
    puts "URL: http://www.imdb.com/title/tt#{movie.id}/"
    puts "=" * 72
    puts
  end

  def console_display_movies_details(movie_list, limit)
    if (limit <= movie_list.size)
      max = limit
    else
      max = movie_list.size
    end
    #movies = movie_list
    movies = movie_list[0, max] # limit to ten top hits

    movies.each do |movie|
      console_display_individual_movie_details(movie)
    end
  end
end


class Imdb_Search_CLI

  def logger
    RAILS_DEFAULT_LOGGER
  end

  def imdb_search(query)

    puts "*****************************************"
    puts "*     IMDB Search                       *"
    puts "*****************************************"

    imdb_helper = IMDB_Helper.new

    if query.match(/\d\d\d\d\d\d\d/)
      # if the query is an ID in IMDB
      movies = imdb_helper.fetch_movie_by_imdb_id(query)
      imdb_helper.console_display_individual_movie_details(movies.first)
    else
      # otherwise, it is looking up the movie by title.
      movies = imdb_helper.search_movie_by_title(query)
      # limiting to display only top 3.
      imdb_helper.console_display_movies_details(movies, 5)
    end

  end
end