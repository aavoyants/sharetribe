class AddPickupDatesToListings < ActiveRecord::Migration
  def change
    add_column :listings, :pickup_date, :datetime
    add_column :listings, :pickup_date_until, :datetime
  end
end
