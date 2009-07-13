class AddAdditionalInfoToDvds < ActiveRecord::Migration
  def self.up
    add_column :dvds, :description, :text
    add_column :dvds, :running_time, :integer
    add_column :dvds, :theatrical_release_date, :text
    add_column :dvds, :dvd_release_date, :text
    add_column :dvds, :region_code, :integer
    add_column :dvds, :director, :text
    add_column :dvds, :actors, :text
    #add_column :dvds, :imdb_id, :integer

    #add_column :dvds, :genre, :text
  end

  def self.down
    remove_columns :dvds, :description
    remove_columns :dvds, :running_time
    remove_columns :dvds, :theatrical_release_date
    remove_columns :dvds, :dvd_release_date
    remove_columns :dvds, :region_code
    remove_columns :dvds, :director
    remove_columns :dvds, :actors
    #remove_columns :dvds, :imdb_id
  end
end
