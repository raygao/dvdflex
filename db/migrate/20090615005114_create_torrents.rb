class CreateTorrents < ActiveRecord::Migration
  def self.up
    create_table :torrents do |t|
      t.integer :dvd_id
      t.text :torrent
      t.text :link
      t.text :size
      t.text :category
      t.text :pubdate

      t.timestamps
    end
  end

  def self.down
    drop_table :torrents
  end
end
