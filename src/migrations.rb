class Hills < ActiveRecord::Migration
  def self.up
    create_table :hills do |t|
      t.string :name
      t.string :location

      t.timestamp
    end
  end
  def self.down
    drop_table :hills
  end
end

unless Hills.table_exists?(:hills)
  ActiveRecord::Migrator.migrate(Hills.up)
end

class Caves < ActiveRecord::Migration
  def self.up
    create_table :caves do |t|
      t.string :name
      t.float  :length
      t.integer :hill_id
      t.string :status

      t.timestamp
    end
  end
  def self.down
    drop_table :caves
  end
end

unless Caves.table_exists?(:caves)
  ActiveRecord::Migrator.migrate(Caves.up)
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
