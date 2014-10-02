class Farms < ActiveRecord::Migration
  def self.up
    create_table :farms do |t|
      t.string :name
      t.string :location

      t.timestamp
    end
  end
  def self.down
    drop_table :farms
  end
end

unless Farms.table_exists?(:farms)
  ActiveRecord::Migrator.migrate(Farms.up)
end

class Animals < ActiveRecord::Migration
  def self.up
    create_table :animals do |t|
      t.string :name
      t.float  :length
      t.integer :farm_id
      t.string :status
      t.string :type

      t.timestamp
    end
  end
  def self.down
    drop_table :animals
  end
end

unless Animals.table_exists?(:animals)
  ActiveRecord::Migrator.migrate(Animals.up)
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
