# ActiveRecord Scopes *without* Rails (and without scopes)


# DISCLAIMER

**I'm not a Rails or ActiveRecord expert!**

It's just part of what I do in my day job.

And, this presentation is largely a result of personal
investigation to improve my own skills.

### YMMV, &c.

Verify everything for yourself!

(Don't just take my word for it.)

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

* Understanding how the ActiveRecord implementation of
scope works.
* Some tips for debugging scopes.
* When and why to pass blocks into scopes.
* (Personal goal) structure and formatting of talk for
  content reuse.

# Review, semantic convenience

Name scopes for the state they describe.

# Review, chaining scopes

What we really want to see here is the underlying SQL, using
the `to_sql` method on the ARel.

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

But we can write a

## driver file

~~~~
@@@ ruby
#!/usr/bin/env ruby

include 'active_record'
include 'active_support'
include 'logger'
include 'rspec'

~~~~

Put the above code in a file named `arscope.rb`.

We'll eventually need all of these gems, so let's include
them now and forgot about them.

Since we're interested in scopes, which are ActiveRecord methods,
we'll need some sort of database connection as well.

# EZ database connection

Let's create a file, `connection.rb`, and in that
file put the following code:

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


# Migrations

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
  scope :is, -> (kind) { where(kind: kind) }
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

# Scopes

Simple explanation, demo/example.

~~~~
@@@ ruby
scope :by_role, -> role { where(role: role) if role.present? }
~~~~

# Should scopes by tested?

Depends.

But probably, yes.

If developing Test-First, certainly. One can (and should) always remove redundant
tests later.

However, no matter anyone's opinion, we're testing scopes in this talk
because it's useful for demonstrating behavior.

# Replace scope with class method


From Blogistan, for replacing a scope with a class method,
we get something like this:

~~~~
@@@ ruby
def self.by_role role
  if role.present?
    where(role: role)
  else
    all
  end
end
~~~~

But that's nasty, don't you think? Let's do it

### Ruby style:

~~~~
@@@ ruby
def self.by_role role
  where(role: role) if role.present? or all
end
~~~~



# Why chaining works

ARel, from the `all` method.

# Some RSpec

* Scope-to-scope chaining
* Scope-to-class method chaining
* Class method-to-scope chaining
* Class method-to-class method chaining

# Scope-to-scope chaining

~~~~
@@@ ruby
it "finds the pet cats" do
  expect(Animal.pets.is("cat").pluck(:name)).to include "Wheezie"
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

* Scope: `is`
* Class method: `by_role`

~~~~
@@@ ruby
it "finds the pet cats by kind and role" do
  expect(Animal.is('cat').by_role('pet').pluck(:name)).to include "Wheezie"
end
~~~~

# Class method-to-scope chaining

* Class method: `by_role`
* Scope: `is`

~~~~
@@@ ruby
it "finds the pet cats by role and kind" do
  expect(Animal.by_role('pet').is('cat').pluck(:name)).to include "Wheezie"
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

# One of the herd...

![Angus bull](/images/black_angus_bull.jpg)

[Photo credit](https://www.flickr.com/photos/brittgow/4782264442/in/photolist-8hAmBd-fWf4Sm-sBhqy-5NLJ75-df1qdX-9QwH67-fURhtT-5GfGPx-oc1RyS-9m1mgj-dyNvbc-9m1m25-dNsw61-9kXfqR-9kXg3P-nQDLMo-ofDppd-fUR3MY-beB9hM-obrYGd-9m1mCy-cDJdLQ-fa6wzB-9m1mkd-odWovP-5NGpo6-7XVsMj-odYJyu-nWxY11-eXrc1F-eNaDtB-m6JPhL-fTwUP-69MC3M-eXrcEe-eXrFQF-eXrETt-5PyTxq-eXrdnk-9wxgb-4suVzj-eXCGkA-nZvHY1-96VcgL-jneb5P-5v15n6-4sa5qJ-5v15aM-5MPgif-5NGrYx)

# How Arel works

TODO: some modest digging through the Rails source to figure
out the central conceit of the Arel design. Already know it
has to return a compatible class, but that class is built
(defined) on the fly.

Is there any way to generalize this to non-relational
database queries?

### AnRel

"Active Non-Relation"

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
* [`dangerous_class_method?`](https://github.com/rails/rails/blob/master/activerecord/lib/active_record/attribute_methods.rb#L148), more source.

# Moar?



# Even moar?

# Haha! No moar!

### The end

For now.

Thanks for your attention.
