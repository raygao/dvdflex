class CreateImdblistings < ActiveRecord::Migration
  def self.up
    create_table :imdblistings do |t|
      t.integer :id
      t.integer :dvd_id
      t.integer :imdb_id
      t.text :title
      t.text :year
      t.text :rating
      t.text :length
      t.text :director
      t.text :actors
      t.text :genre
      t.text :plot
      t.text :url

      t.timestamps
    end
  end

  def self.down
    drop_table :imdblistings
  end
end
