#!/usr/bin/env ruby

require 'active_record'
require 'active_support'
require 'logger'
require 'rspec'
require 'ap'

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
  def method_missing arg1, arg2
    puts "LocalScoper method_missing..."
    ap "Method #{arg1} with #{arg2} is missing"
    nil
  end

  # https://github.com/rails/rails/blob/master/activerecord/lib/active_record/scoping/named.rb
  # define method_missing to get this working for now.
  def scope(name, body, &block)

    ret_val = dangerous_class_method?(name)
    ap "#{__FILE__} #{__LINE__} ret_val: #{ret_val.class}"

    if dangerous_class_method?(name)
      raise ArgumentError, "You tried to define a scope named \"#{name}\" " \
        "on the model \"#{self.name}\", but Active Record already defined " \
        "a class method with the same name."
    end

    ap "From LocalScoper"

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

load './animal.rb'

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
i4 = Animal.new :name => "animal 5", length: 42.13
#o4.animal = i4

#ActiveRecord::Base.logger = Logger.new(STDOUT)

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end

describe Farm do
  let(:farm) { Farm.new }

  it "creates a valid farm" do
    expect(farm).to be_valid
  end
end

describe Animal do

  let(:animal) { Animal.new }

  it "new animal should be valid" do
    animal.should be_valid
  end

  it "makes a scope" do
    ## Put this on a slide
    Animal.scope("foo", -> {}) # { "quux" }
    expect(Animal.foo.count).to be >= 0
    Animal.methods.should  include :foo
  end

  # Need to load an animal in the db such that this test passes.
  # Experiment with defining the scopes on the fly in the test.
  it "chains two scopes" do
    #expect(animal.foo.bar.first.amount).to eq 42.13
    Animal.create :name => "animal 4", length: 42.13
    expect(Animal.foo.bar.first.length).to eq 42.13
  end

  xit "does not allow duplicate scope names" do
    Animal.scope :bar, -> { where(name: "animal 1") } { puts "foo" }
    expect {
      Animal.scope :bar, -> { where(name: "animal 1") }
      #animal.scope :quux, -> { where(name: "animal 1") }
    }.to raise_error ArgumentError

    expect { animal.scope :bar, -> {} }.to raise_error
  end
end
