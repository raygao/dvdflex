class AddVodToDvds < ActiveRecord::Migration
  def self.up
      add_column :dvds, :vod, :text
  end

  def self.down
    remove_columns :dvds, :vod
  end
end
