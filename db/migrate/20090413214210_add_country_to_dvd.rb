class AddCountryToDvd < ActiveRecord::Migration
  def self.up
    add_column :dvds, :country_id, :integer
  end

  def self.down
    remove_column :dvds, :country_id
  end
end
