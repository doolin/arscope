#!/usr/bin/env ruby
# frozen_string_literal: true

require 'active_record'
# require 'active_support'
require 'logger'
require 'rspec'
# require 'pry-nav'

# https://github.com/ruby/debug
# TODO: practice using debug gem.
require 'debug'
# require 'ap'

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
  inflect.plural 'animal', 'animals'
end

require './lib/connection'
require './lib/migrations'

# To ensure we get an ARel back, we may need to monkey
# patch:
# module ActiveRecord
#   # = Active Record \Named \Scopes
#   module Scoping
#     module Named
module LocalScoper
  def my_method_missing(arg1, arg2)
    # puts "#{__FILE__} #{__LINE__} LocalScoper method_missing..."
    ap "Method #{arg1} with #{arg2} is missing"
    # nil
  end

  # https://github.com/rails/rails/blob/master/activerecord/lib/active_record/scoping/named.rb
  # define method_missing to get this working for now.
  def my_scope(name, body, &block)
    #     ret_val = dangerous_class_method?(name)
    #     ap "#{__FILE__} #{__LINE__} ret_val: #{ret_val.class}"
    #
    #     if dangerous_class_method?(name)
    #       raise ArgumentError, "You tried to define a scope named \"#{name}\" " \
    #         "on the model \"#{self.name}\", but Active Record already defined " \
    #         "a class method with the same name."
    #     end

    # ap "From LocalScoper"

    extension = Module.new(&block) if block

    singleton_class.send(:define_method, name) do |*args|
      scope = all.scoping { body.call(*args) }
      scope = scope.extending(extension) if extension

      scope || all
    end
  end
end

require './lib/animal'
require './lib/farm'

ActiveRecord::Base.logger = Logger.new($stdout)

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = %i[should expect]
  end
end

describe Animal do
  let(:animal) { Animal.new }

  # This is nasty.
  before(:all) { require_relative '../lib/seed' }

  it 'new animal should be valid' do
    animal.should be_valid
  end

  it 'it finds the pets' do
    expect(Animal.pets.count).to eq 2
  end

  it 'finds no show animals which need the vet' do
    expect(Animal.show.needs_vet.count).to eq 0
  end

  it 'it finds overdue for vet' do
    expect(Animal.needs_vet.count).to eq 4
  end

  it 'finds the pet for a vet' do
    expect(Animal.pets.needs_vet.count).to eq 1
  end

  it 'makes a scope' do
    ## Put this on a slide
    Animal.scope('foo', -> {}) # { "quux" }
    expect(Animal.foo.count).to be >= 0
    Animal.methods.should include :foo
  end

  # Need to load an animal in the db such that this test passes.
  # Experiment with defining the scopes on the fly in the test.
  xit 'chains two scopes' do
    # expect(animal.foo.bar.first.amount).to eq 42.13
    Animal.create name: 'animal 4', weight: 42.13
    expect(Animal.foo.bar.first.weight).to eq 42.13
  end

  #   # Set this up to test the scopes first.
  #   # Testing scopes is important when replacing AR.
  #   it "handles non-existent attributes" do
  #     #puts Animal.by_role("working").by_name("Bessie").inspect
  #     expect(Animal.by_role("working").by_name("Bessie").first.name).to eq "Bessie"
  #   end
  #
  #   it "finds the pet cats" do
  #     expect(Animal.pets.by_kind("cat").pluck(:name)).to include "Wheezie"
  #   end
  #
  #   it "finds the pet cats by kind and role" do
  #     expect(Animal.by_kind('cat').by_role('pet').pluck(:name)).to include "Wheezie"
  #   end
  #
  #   it "finds the pet cats by role and kind" do
  #     expect(Animal.by_role('pet').by_kind("cat").pluck(:name)).to include "Wheezie"
  #   end
  #
  #   it "does stuff with the breed class method" do
  #     puts Animal.by_breed("maine coon").to_sql
  #   end
  #
  #   # In this case, Shredder the pet goat has no breed specified.
  #   it "does stuff with the breed class method empty string" do
  #     puts Animal.by_breed('').to_sql
  #     expect(Animal.by_breed('').size).to eq 1
  #   end
  #
  #   it "does stuff with the breed class method passed a nil" do
  #     puts Animal.by_breed(nil).to_sql
  #     expect(Animal.by_breed(nil).pluck(:kind)).to include "mule"
  #   end

  xit 'finds all the cats and their roles' do
    cats = Animal.by_kind('cat').by_role('pet').to_sql # .pluck(:name)
    puts cats.inspect
    cats = Animal.by_kind('cat').by_role('').to_sql # .pluck(:name)
    puts cats.inspect
    cats = Animal.by_kind('cat').by_role(nil).to_sql # .pluck(:name)
    puts cats.inspect
    cats = Animal.by_kind('cat').by_role(nil) # .pluck(:name)
    puts cats.inspect
    puts Animal.by_role('working').to_sql
    expect(Animal.by_kind('cat').by_role('pet').pluck(:name)).to include 'Wheezie'
  end

  #   it "finds all the angus" do
  #     expect(Animal.by_role('stock').by_breed('angus').size).to eq 2
  #   end
  #
  #   it "silently allows duplicate scope definitions" do
  #     Animal.scope :testem, -> { where(name: "animal 1") } #{ puts "foo" }
  #     expect {
  #       Animal.scope :testem, -> { where(name: "animal 1") }
  #     }.not_to raise_error
  #   end

  #   xit "does not allow duplicate scope names" do
  #     Animal.scope :utotem, -> { where(name: "animal 1") } #{ puts "foo" }
  #     #expect { Animal.scope :utotem, -> { where(role: "working") } }.to raise_error ArgumentError
  #     #expect { Animal.scope :utotem, -> {} }.to raise_error ArgumentError
  #   end
  #
  #   xit "yields a block passed to a scope extension" do
  #     expect(Animal.yielder.yieldit { "yielded" }).to eq "yielded"
  #   end
  #
  #   xit "exercises a scope" do
  #     # work returns a string instead of a relation,
  #     # next step is to see if it can return a relation
  #     # and be chained.
  #     #ap Animal.by_kind('dog').work('dog').to_sql
  #     expect(Animal.by_kind('dog').work('dog')).to eq 'herd'
  #   end
  #
  #   it "fails on wacko sql" do
  #     # Animal.scope :badscope, -> { where("? - date.now.to_i > max_value", Time.now.utc.to_i) }
  #
  #     # Uncomment this to acquire failure specifics.
  #     # expect(Animal.badscope).not_to be_empty
  #
  #     # puts Animal.badscope.to_sql
  #     # We need to force an evaluation, `puts` its convenient.
  #     # (This is a good segue into lazy evaluation.)
  #     expect {
  #       puts Animal.badscope
  #     }.to raise_error(ActiveRecord::StatementInvalid)
  #   end
end
