#!/usr/bin/env ruby

require 'active_record'
require 'active_support'
# require 'protected_attributes'
require 'logger'
require 'rspec'
require 'ap'

#####
####  Rails scopes are class methods invoked by instances.

# Create a class with a scope and a class method and chain the two of them together.
# http://blog.plataformatec.com.br/2013/02/active-record-scopes-vs-class-methods/

# WHY:
# * scopes can be chained
# * semantically convenient shorthand
# http://stackoverflow.com/questions/9728623/what-is-the-real-benefit-of-scopes
#
# WHEN:
# * Whenever predefined queries simplify code.
#
#
# HOW:
#
# WHAT:

load './connection.rb'
load './post_migration.rb'
require './post_model'

describe Post do
  before :all do
    Post.create title: 'Post 1', author: 'A. N. Author', category: 'horror', status: 'draft'
    Post.create title: 'Post 2', author: 'A. Writer', category: 'history', status: 'draft'
    Post.create title: 'Post 3', author: 'A. N. Author', category: 'science', status: 'draft'
    Post.create title: 'Post 4', author: 'JRR Tolkien', category: 'fantasy', status: 'out of print'
  end

  it 'returns a relation' do
    expect(Post.all.class).to eq ActiveRecord::Relation::ActiveRecord_Relation_Post
  end

  it 'writes out some sql for argument' do
    puts Post.by_author('Dave').to_sql
  end

  it 'writes out some sql for argument' do
    puts Post.by_author('').to_sql
  end

  it 'chains 2 class methods' do
    puts Post.by_author('').by_title('Jabberwocky').to_sql
  end

  it 'chains 2 class methods' do
    puts Post.by_author('JRR Tolkien').by_title('Return of the King').to_sql
  end
end
