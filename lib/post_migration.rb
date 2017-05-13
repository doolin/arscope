class Posts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string :status
      # This is interesting aspect of lazy loading.
      # If the attribute isn't defined, ARel will still
      # generate the sql, without actually performing the
      # query.
      # t.integer wordcount
      t.string :author
      t.string :title
      t.string :category

      t.timestamp
    end
  end

  def self.down
    drop_table :post
  end
end

ActiveRecord::Migrator.migrate(Posts.up) unless Posts.table_exists?(:posts)
