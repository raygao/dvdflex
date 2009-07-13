class AddPageurlToDvd < ActiveRecord::Migration
  def self.up
        add_column :dvds, :pageurl, :text
  end

  def self.down
    remove_column :dvds, :pageurl
  end
end
