class Orders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.string :name
      t.string :address

      t.timestamp
    end
  end
  def self.down
    drop_table :orders
  end
end

unless Orders.table_exists?(:orders)
  ActiveRecord::Migrator.migrate(Orders.up)
end

class Invoices < ActiveRecord::Migration
  def self.up
    create_table :invoices do |t|
      t.string :name
      t.float  :amount
      t.integer :order_id
      t.string :status

      t.timestamp
    end
  end
  def self.down
    drop_table :invoices
  end
end

unless Invoices.table_exists?(:invoices)
  ActiveRecord::Migrator.migrate(Invoices.up)
end

=begin
class LocalScopers < ActiveRecord::Migration
  def self.up
    create_table :local_scopers do |t|
      t.string :name
      t.timestamp
    end
  end
  def self.down
    drop_table :local_scopers
  end
end
=end

#unless LocalScopers.table_exists?(:local_scopers)
#  ActiveRecord::Migrator.migrate(LocalScopers.up)
#end
