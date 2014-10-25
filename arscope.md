# ActiveRecord Scopes *without* Rails (and without scopes)


# DISCLAIMER

**I'm not a Rails or ActiveRecord expert!**

It's just part of what I do in my day job.

And, this presentation is largely a result of personal
investigation to improve my own skills.

### YMMV, &c.

Verify everything for yourself!

(Don't just take my word for it.)

# Personal motivation

We're moving a lot of data out of Postgres and into Cassandra,
hence we lose all our ActiveRecord goodies , for example, the
`scope` method.

### But we still have to do everything the scopes were doing

A necessary first step:

## change scopes into class methods

Specifically, how much could I leverage Rails patterns
for NoSQL tools?

The answer to that is still open, but there is plenty
of tasty Rails treats here.

# The view from 80,000 feet

![Blackbird can see you](/images/sr71.jpg)


# Why ActiveRecord scopes?

Two main reasons:

1. Scopes provide a semantically convenient shorthand for SQL
   statements.
1. Scopes can be *chained*, tremendously easing the cognitive load of
   creating the correct SQL for complicated queries.

### Basically, scopes allow defining custom database queries and query fragments

# What we want to get out of this

* Some understanding how the ActiveRecord implementation of
scope works.
* How chaining scopes works.
* How class methods can chain with scopes.
* How to control queries on parameter values.
* Some tips for debugging scopes. (Hint: use `to_sql`)
* When and why to pass blocks into scopes.
* (Personal goal) structure and formatting of talk for
  content reuse. That is, can this talk be delivered on a Kindle?

# Review: `scope` definition

The method definition of scope has 3 parts.

~~~~
@@@ ruby
  # activerecord/lib/active_record/scoping/named.rb
  def scope(name, body, &block)
    if dangerous_class_method?(name)
      raise ArgumentError, "Already defined scope"
    end

    extension = Module.new(&block) if block

    singleton_class.send(:define_method, name) do |*args|
      scope = all.scoping { body.call(*args) }
      scope = scope.extending(extension) if extension

      scope || all
    end
  end
~~~~

# 3 part definition

1. check for existing scope name
2. build scope extension if block present
3. define the scope as a class method on the current ActiveRecord model.

# Scary! `dangerous_class_method?`

### (scope def. part 1)

First order of business: has a scope by this name already been defined,
or does is the scope name a reserved words?

Reserved words, can't name a scope any of these:

~~~~
@@@ ruby
  # active_record/scoping/named.rb:142
  if dangerous_class_method?(name)
    raise ArgumentError, "Already defined scope"
  end
~~~~

### Did you know?

This presentation has an Appendix, where you can find the definition of
`dangerous_class_method?`.

# Define scope extension

### (scope def. part 2)

~~~~
@@@ ruby
  # active_record/scoping/named.rb:148
  extension = Module.new(&block) if block
~~~~

Apparently, few people have heard of scope extensions, and fewer seem to
use them.

We'll return to scope extensions later.

# Define scope as class method

### (scope def. part 3)

~~~~
@@@ ruby
  # active_record/scoping/named.rb:150
  singleton_class.send(:define_method, name) do |*args|
    scope = all.scoping { body.call(*args) }
    scope = scope.extending(extension) if extension

    scope || all
  end
~~~~

# Review: scopes help generate queries

What we really want to see here is the underlying SQL, using
the `to_sql` method on the ARel.

Simple explanation, demo/example.

~~~~
@@@ ruby
class Animal
  scope :by_role, -> role { where(role: role) }
end

2.1.2 :001 > Animal.by_role('working').to_sql
 => "SELECT \"animals\".* FROM \"animals\"  WHERE \"animals\".\"role\" = 'working'"
~~~~


# Kindle-sized code snippets

This talk is also, in part, an experiment in cross-platform
code readability.

Specifically, can code be discussed on devices as small
as Kindle?

We won't find out here, but this is step along that path.

# Begin at the beginning

What we really want is a single file application, where
all the various bits represent the important parts.

That won't fly in a presentation, it won't fit on a slide.

Won't fit on Kindle screen either.

But we can write a driver file named `arscope.rb`.

## driver file `arscope.rb`

~~~~
@@@ ruby
  #!/usr/bin/env ruby

  include 'active_record'
  include 'active_support'
  include 'logger'
  include 'rspec'
~~~~

Since we're interested in scopes, which are ActiveRecord methods,
we'll need some sort of database connection as well.

# EZ database connection

Let's create a file, `connection.rb`, with the following code:

~~~~
@@@ ruby
  DB_SPEC = {
    adapter: "sqlite3",
    database: "scope.sqlite3",
    pool: 5,
    timeout: 5000
  }

  ActiveRecord::Base.establish_connection(DB_SPEC)
~~~~

Now we load it....

~~~~
@@@ ruby
  #!/usr/bin/env ruby

  include 'active_record'
  include 'active_support'
  include 'logger'
  include 'rspec'

  load './connection.rb'
~~~~

# Example domain: Farm

![Farm](/images/farm.jpg)

[Photo credit](https://www.flickr.com/photos/cindy47452/13881944095)


# Migrations (farms have animals)

~~~~
@@@ ruby
class Animals < ActiveRecord::Migration
  def self.up
    create_table :animals do |t|
      t.string :name
      # Why can't we use `type` here?
      # t.string :type
      t.string :kind
      t.string :breed
      t.string :role
      t.datetime :last_vet
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
~~~~

We might add more migrations later, but they won't fit on the slide.

(We could load each migration from its own file...)

# And, once again...

~~~~
@@@ ruby
  #!/usr/bin/env ruby

  include 'active_record'
  include 'active_support'
  include 'logger'
  include 'rspec'

  load './connection.rb'
  load './migrations.rb'
~~~~


# How 'bout a model, then...

Create a file `animal.rb`:

~~~~
@@@ ruby
class Animal < ActiveRecord::Base
  scope :pets, -> { where(role: 'pet') }
  scope :by_kind, -> (kind) { where(kind: kind) }
end
~~~~


# Yet again...

~~~~
@@@ ruby
#!/usr/bin/env ruby

include 'active_record'
include 'active_support'
include 'logger'
include 'rspec'

load './connection.rb'
load './migrations.rb'
load './animal.rb'
~~~~

From here on out, let's assume we're all smart enough to remember
to add the new file.

# Should scopes be tested?

Depends.

But probably, yes.

If developing Test-First, certainly. One can (and should) always remove redundant
tests later.

However, no matter anyone's opinion,

### we're testing scopes in this talk,

because it's useful for demonstrating behavior.

# And here's how we're testing scopes...

~~~~
@@@ ruby
  #!/usr/bin/env ruby

  include 'active_record'
  include 'active_support'
  include 'logger'
  include 'rspec'

  load './connection.rb'
  load './migrations.rb'
  load './animal.rb'

  describe Animal do
    before(:all) { require './seed' }
    it "finds the pets" do
      expect(Animal.pets.count).to eq 2
    end
  end
~~~~


# Replace scope with class method

From Blogistan, for replacing a scope with a class method,
we get something like this:

~~~~
@@@ ruby
def self.by_kind kind
    where(kind: kind)
end
~~~~

It's that simple.


# Why chaining works

Chaining, in general, works by sending a message to the method on the
returned object.

Example: `"Foo".downcase.reverse => "oof"`

* `downcase` returns a String object
* `reverse` is called on the String object returned from `downcase`

### Why chaining scopes works

`QueryMethods`, from
[ActiveRecord::Relation (Arel)](https://github.com/rails/rails/blob/master/activerecord/lib/active_record/relation/query_methods.rb) return Arel objects.


# Some RSpec

* Scope-to-scope chaining
* Scope-to-class method chaining
* Class method-to-scope chaining
* Class method-to-class method chaining

# Scope-to-scope chaining

~~~~
@@@ ruby
it "finds the pet cats" do
  expect(Animal.pets.by_kind("cat").pluck(:name)).to include "Wheezie"
end
~~~~

# Wheezy the Maine Coon

![Wheezy](/images/maine_coon_wheezy.jpg)


# More useful scopes and methods

~~~~
@@@ ruby
class Animal < ActiveRecord::Base
  scope :needs_vet, -> { where("last_vet < ?", 1.year.ago) }
  scope :by_name, -> (n) { where(name: n) }

  def self.working
    where(kind: 'working')
  end

  def self.show
    where(kind: 'show')
  end

  def self.by_breed breed
    where(breed: breed)
  end

  def self.by_role role
    where(role: role)
  end
~~~~


# Scope-to-class method chaining

* Scope: `by_kind`
* Class method: `by_role`

~~~~
@@@ ruby
it "finds the pet cats by kind and role" do
  expect(Animal.by_kind('cat').by_role('pet').pluck(:name)).to include "Wheezie"
end
~~~~

# Class method-to-scope chaining

* Class method: `by_role`
* Scope: `by_kind`

~~~~
@@@ ruby
it "finds the pet cats by role and kind" do
  expect(Animal.by_role('pet').by_kind('cat').pluck(:name)).to include "Wheezie"
end
~~~~


# Class method-to-class method chaining

* Class method: `by_role`
* Class method: `by_breed`

~~~~
@@@ ruby
it "finds all the angus" do
  expect(Animal.by_role('stock').by_breed('angus').size).to eq 2
end
~~~~

# One of the Angus herd...

![Angus bull](/images/black_angus_bull.jpg)

[Photo credit](https://www.flickr.com/photos/brittgow/4782264442/in/photolist-8hAmBd-fWf4Sm-sBhqy-5NLJ75-df1qdX-9QwH67-fURhtT-5GfGPx-oc1RyS-9m1mgj-dyNvbc-9m1m25-dNsw61-9kXfqR-9kXg3P-nQDLMo-ofDppd-fUR3MY-beB9hM-obrYGd-9m1mCy-cDJdLQ-fa6wzB-9m1mkd-odWovP-5NGpo6-7XVsMj-odYJyu-nWxY11-eXrc1F-eNaDtB-m6JPhL-fTwUP-69MC3M-eXrcEe-eXrFQF-eXrETt-5PyTxq-eXrdnk-9wxgb-4suVzj-eXCGkA-nZvHY1-96VcgL-jneb5P-5v15n6-4sa5qJ-5v15aM-5MPgif-5NGrYx)

# Scope extensions

First, question: Who in the audience is using scope extensions on a
regular basis?

Simple example:

~~~~
@@@ ruby

scope :foo, -> { where(bar: 'baz') } do
  def quux
    'foobar'
  end
end

# Debugging scopes

It's not hard to blunder in scope definitions.

One favorite way of mine is mixing Ruby with SQL.

ActiveRecord is perfectly happy to define perfectly invalid SQL,
which leaves debugging up to us Rubyists.

Consider the following:

~~~~
@@@ ruby
  scope :badscope, -> { where("? - Date.now.to_i > max_value", Time.now.utc.to_i) }
~~~~

### Looks perfectly reasonable...at first glance.

Even the SQL looks somewhat reasonable:

~~~~
@@@ sql
SELECT "animals".* FROM "animals"  WHERE (1413899468 - Date.now.to_i > max_value)
~~~~


# Let's see what the database has to say...

~~~~
@@@ sql
sqlite> SELECT "animals".* FROM "animals"  WHERE (1413899468 - date.now.to_i > max_value);
Error: no such column: date.now.to_i
~~~~

### Ha ha.

You think it's funny now (and it is), but spend a couple of hours at the
end of the week trying to figure out why your *Rails* application isn't
working.


# REPL is your friend

You can test these out in Rails console, or open up a database
connection (`rails db`).

Sans Rails, just fire up a database client.

Either way, paste in the result of `to_sql` on the scope and
see what the database thinks about it.

### And so are scope tests!

~~~~
@@@ ruby
Failure/Error: expect(Animal.badscope).not_to be_empty
     ActiveRecord::StatementInvalid:
       SQLite3::SQLException: no such column: date.now.to_i: SELECT
COUNT(*) FROM "animals"  WHERE (1413985311 - date.now.to_i > max_value)
~~~~

# Testing a scope with RSpec

~~~~
@@@ ruby
  it "fails bad scope definition on wacko (invalid) sql" do
    # Uncomment this to acquire failure specifics.
    # expect(Animal.badscope).not_to be_empty
    # We need to force an evaluation, `puts` its convenient.
    # (This is a good segue into lazy evaluation.)
    expect {
      puts Animal.badscope
    }.to raise_error(ActiveRecord::StatementInvalid)
  end
~~~~

## Summarizing

As web programmers, we're polyglot, we have to program competently in
several programming languages every day.

The upshot here: when I've been looking at Ruby all day long, sometimes
shifting gears into SQL doesn't.

# How about "AnRel" (Active Non-Relation)

Is there any way to generalize this to non-relational
database queries?

### AnRel


Create a wrapper around the query structure of the non-relational
system, ensure whatever replaces `scope` returns the non-relation
on every call.


# Caveats

As usual, employ (or deploy) at your own risk:

1. Scopes are what people expect to see in ActiveRecord based models.

2. If you're using ActiveRecord in a non-Rails system,
   it's probably worth rethinking that once in a while. ActiveRecord
   plays well with Rails for a reason (it was designed in).

3. ??? You tell me.


# Summarizing

This wasn't especially long, but it was dense. Here are a few links
for digging deeper:

### Links

* [Scopes vs. class methods](http://blog.plataformatec.com.br/2013/02/active-record-scopes-vs-class-methods/)
  from Platformatec.
* [Method
  chaining](http://jeffkreeftmeijer.com/2011/method-chaining-and-lazy-evaluation-in-ruby/)
  from Jeff Kreeftmeijer.
* [Class structure for method
  chaining](http://tjackiw.tumblr.com/post/23155838377/interview-challenge-ruby-method-chaining).
* [Extending vs
  including](http://www.medihack.org/2011/03/15/intend-to-extend/) good refresher article.
* [Rails named scope
  definition](https://github.com/rails/rails/blob/master/activerecord/lib/active_record/scoping/named.rb)
  can't go wrong with source code.
* [`blank` and
  `present?`](http://guides.rubyonrails.org/active_support_core_extensions.html#blank-questionmark-and-present-questionmark) from the Ruby on Rails Guide.
* [`blank` and `present?`](https://github.com/rails/rails/blob/master/activesupport/lib/active_support/core_ext/object/blank.rb) from the Rails source code.
* [`dangerous_class_method?`](https://github.com/rails/rails/blob/master/activerecord/lib/active_record/attribute_methods.rb#L148), more source.

# Appendix

# `dangerous_class_method?`

~~~~
@@@ ruby
  # activerecord/lib/active_record/attribute_methods.rb
  BLACKLISTED_CLASS_METHODS = %w(private public protected allocate new name parent superclass)

  # A class method is 'dangerous' if it is
  # already (re)defined by Active Record, but
  # not by any ancestors. (So 'puts' is not dangerous but 'new' is.)
  def dangerous_class_method?(method_name)
    BLACKLISTED_CLASS_METHODS.include?(method_name.to_s)
    || class_method_defined_within?(method_name, Base)
  end

  def class_method_defined_within?(name,
    klass, superklass = klass.superclass) # :nodoc

    if klass.respond_to?(name, true)
      if superklass.respond_to?(name, true)
        klass.method(name).owner != superklass.method(name).owner
      else
        true
      end
    else
      false
    end
  end

# `all`

~~~~
@@@ ruby
  # Returns an <tt>ActiveRecord::Relation</tt> scope object.
  # [snip snap]
  # You can define a scope that applies to all finders using
  # <tt>ActiveRecord::Base.default_scope</tt>.
  def all
    if current_scope
      current_scope.clone
    else
      default_scoped
    end
  end

  def default_scoped # :nodoc:
    relation.merge(build_default_scope)
  end
~~~~


# Controlling queries on parameterized scopes

Consider the following definitions:

~~~~
@@@ ruby
scope :by_kind, ->(k) { where(kind: k) }
scope :by_role, ->(r) { where(role: r) }
~~~~

with query:

~~~~
@@@ ruby
Animal.by_kind('cat').by_role('pet')
~~~~

which produces the follow SQL:

~~~~
@@@ sql
SELECT * FROM animals  WHERE kind = 'cat' AND role = 'pet'
~~~~

# When parameter isn't `present?`

~~~~
@@@ sql
SELECT * FROM animals WHERE kind = 'cat' AND role = ''

SELECT * FROM animals  WHERE kind = 'cat' AND role IS NULL
~~~~
# When `nil` and `blank` matter

From Blogistan, for replacing a scope with a class method,
we get something like this:

~~~~
@@@ ruby
def self.by_kind kind
  if kind.present?
    where(kind: kind)
  else
    all # return arel when kind.nil?
  end
end
~~~~

But that's nasty, don't you think? Let's do it

### Ruby style:

~~~~
@@@ ruby
def self.by_kind kind
  where(kind: kind) if kind.present? or all
end
~~~~

# Extending class methods

Just as scopes can be extended, so can class methods:

Platformatec demonstrates how this is done using the `kaminari`
pagination gem:

~~~~
@@@ ruby
def self.page(num)
  scope = # some limit + offset logic here for pagination
  scope.extend PaginationExtensions
  scope
end

module PaginationExtensions
  def per(num)
    # more logic here
  end

  def total_pages
    # some more here
  end

  def first_page?
    # and a bit more
  end

  def last_page?
    # and so on
  end
end
~~~~


# How to name ActiveRecord scopes

Name scopes for the state they describe.
