class CreateListings < ActiveRecord::Migration
  def self.up
    create_table :listings do |t|
      t.integer :user_id
      t.text :note
      t.integer :status

      t.timestamps
    end
  end

  def self.down
    drop_table :listings
  end
end
