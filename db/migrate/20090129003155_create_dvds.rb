class CreateDvds < ActiveRecord::Migration
  def self.up
    create_table :dvds do |t|
      t.text :upc
      t.text :title
      t.text :medium_image
      t.text :small_image

      t.timestamps
    end

    # Adding foreign key reference to 'Listings' table
    add_column :listings, :dvd_id, :integer
  end

  def self.down
    drop_table :dvds
    remove_column :listings, :dvd_id
  end
end
