#!/usr/bin/env ruby

require 'active_record'
require 'active_support'
require 'logger'
require 'rspec'
require 'pry-nav'
#require 'ap'

#####
####  Rails scopes are class methods invoked by instances.

#Create a class with a scope and a class method and chain the two of them together.
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
# * By defining class methods which query active record and return
#   (possibly empty) relations.
#
# WHAT:
#

# for x in `gem list --no-versions`; do gem uninstall $x -a -x -I; done

### TODO check rails source code for module and class structure
# of scope, then model that here. Inheriting from ActiveRecord::Base
# doesn't seem to work very well.

# Purpose of this cabochon is twofold:
# 1. demonstrate how scopes work,
# 2. provide enough code and data to demonstrate how to
#    debug scopes using command line/pry and db client.
#
# Debugging scope:
# 1. create a scope
# 2. invoke the scope at Rails console
# 3. use db client to debug query
#
# example query:
# -> { where((? - date.now.to_i) > max_value), Time.now.utc.to_i }

# Good post on before_save:
# http://siddharthdawara.blogspot.com/2008/09/rails-beforesave-and-validations.html
# Here's the link to the source for scope:
# https://github.com/rails/rails/blob/master/activerecord/lib/active_record/scoping/named.rb

# Great article on scopes
# http://blog.plataformatec.com.br/2013/02/active-record-scopes-vs-class-methods/

# Scopes are chainable
# to_sql on scopes, or more precisely, the arel returned?

ActiveSupport::Inflector.inflections do |inflect|
  inflect.plural "animal", "animals"
end


load './connection.rb'
load './migrations.rb'

# To ensure we get an ARel back, we may need to monkey
# patch:
# module ActiveRecord
#   # = Active Record \Named \Scopes
#   module Scoping
#     module Named
module LocalScoper
  def my_method_missing arg1, arg2
    #puts "#{__FILE__} #{__LINE__} LocalScoper method_missing..."
    ap "Method #{arg1} with #{arg2} is missing"
    #nil
  end

  # https://github.com/rails/rails/blob/master/activerecord/lib/active_record/scoping/named.rb
  # define method_missing to get this working for now.
  def my_scope(name, body, &block)

=begin
    ret_val = dangerous_class_method?(name)
    ap "#{__FILE__} #{__LINE__} ret_val: #{ret_val.class}"

    if dangerous_class_method?(name)
      raise ArgumentError, "You tried to define a scope named \"#{name}\" " \
        "on the model \"#{self.name}\", but Active Record already defined " \
        "a class method with the same name."
    end
=end

    #ap "From LocalScoper"

    extension = Module.new(&block) if block

    singleton_class.send(:define_method, name) do |*args|
      scope = all.scoping { body.call(*args) }
      scope = scope.extending(extension) if extension

      scope || all
    end
  end
end

class Farm < ActiveRecord::Base
  has_many :animals

  scope :long, -> { where("length > 1000") }
end

puts "before loading animal"
load './animal.rb'
puts "after loading animal"

# http://guides.rubyonrails.org/initialization.html

# Assign an object to a has_one association in an existing object,
# that associated object will be saved.
# Read from p. 323 in Agile 3rd Edition on CRUD.
o1 = Farm.create :name => "farm 1"
i1 = Animal.new :name => "animal 1"
#o1.animals = [i1]

o2 = Farm.new :name => "farm 2"
i2 = Animal.new :name => "animal 2"
i2.save

o3 = Farm.new :name => "farm 3"
o3.save

# Same as scenario 1, using new instead of create
# Nothing gets saved
o4 = Farm.new :name => "farm 4"
i4 = Animal.new :name => "animal 5", weight: 42.13
#o4.animal = i4

#ActiveRecord::Base.logger = Logger.new(STDOUT)

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end

describe Animal do

  let(:animal) { Animal.new }

  before :all do
    # Nasty kludge. You can do better than this.
    require './seed'
  end

  it "new animal should be valid" do
    animal.should be_valid
  end

  it "it finds the pets" do
    expect(Animal.pets.count).to eq 2
  end

  it "finds no show animals which need the vet" do
    expect(Animal.show.needs_vet.count).to eq 0
  end

  it "it finds overdue for vet" do
    #binding.pry
    expect(Animal.needs_vet.count).to eq 4
  end

  it "finds the pet for a vet" do
    expect(Animal.pets.needs_vet.count).to eq 1
  end

  it "makes a scope" do
    ## Put this on a slide
    Animal.scope("foo", -> {}) # { "quux" }
    expect(Animal.foo.count).to be >= 0
    Animal.methods.should  include :foo
  end

  # Need to load an animal in the db such that this test passes.
  # Experiment with defining the scopes on the fly in the test.
  xit "chains two scopes" do
    #expect(animal.foo.bar.first.amount).to eq 42.13
    Animal.create :name => "animal 4", weight: 42.13
    expect(Animal.foo.bar.first.weight).to eq 42.13
  end

  # Set this up to test the scopes first.
  # Testing scopes is important when replacing AR.
  it "handles non-existent attributes" do
    #puts Animal.by_role("working").by_name("Bessie").inspect
    expect(Animal.by_role("working").by_name("Bessie").first.name).to eq "Bessie"
  end

  it "finds the pet cats" do
    expect(Animal.pets.is("cat").pluck(:name)).to include "Wheezie"
  end

  it "finds the pet cats by kind and role" do
    expect(Animal.is('cat').by_role('pet').pluck(:name)).to include "Wheezie"
  end

  it "finds the pet cats by role and kind" do
    expect(Animal.by_role('pet').is("cat").pluck(:name)).to include "Wheezie"
  end

  it "finds all the cats and their roles" do
    cats = Animal.is('cat').by_role('pet').to_sql#.pluck(:name)
    puts cats.inspect
    cats = Animal.is('cat').by_role('').to_sql#.pluck(:name)
    puts cats.inspect
    cats = Animal.is('cat').by_role(nil).to_sql#.pluck(:name)
    puts cats.inspect
    cats = Animal.is('cat').by_role(nil)#.pluck(:name)
    puts cats.inspect
    expect(Animal.is('cat').by_role('pet').pluck(:name)).to include "Wheezie"
  end

  it "finds all the angus" do
    expect(Animal.by_role('stock').by_breed('angus').size).to eq 2
  end

  it "silently allows duplicate scope definitions" do
    Animal.scope :testem, -> { where(name: "animal 1") } #{ puts "foo" }
    expect {
      Animal.scope :testem, -> { where(name: "animal 1") }
    }.not_to raise_error
  end

  xit "does not allow duplicate scope names" do
    Animal.scope :utotem, -> { where(name: "animal 1") } #{ puts "foo" }
    #expect { Animal.scope :utotem, -> { where(role: "working") } }.to raise_error ArgumentError
    expect { Animal.scope :utotem, -> {} }.to raise_error ArgumentError
  end
end
