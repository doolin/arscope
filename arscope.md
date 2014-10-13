# ActiveRecord Scopes with Rails (and without scopes)


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


For now, just the one `orders` table:

~~~~
@@@ ruby
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

Create a file `invoice.rb`:

~~~~
@@@ ruby

class Invoice < ActiveRecord::Base
  # TODO: explain why we want to extend rather than include,
  # and how that implies a scope is not much different than
  # a regular Ruby class method.
  #extend LocalScoper

  belongs_to :order

  scope :bar, -> { where(name: "Invoice 1") }
#=begin
  scope :bar, -> { where(name: "Invoice 2") } do
    "foo"
  end
#=end

  protected

  class << self
    def valid_scope_name? name
      if respond_to?(name, true)
        raise "Overwriting scope #{name}"
      end
    end
  end
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
load './animals.rb'
~~~~

From here on out, let's assume we're all smart enough to remember
to add the new file.

# Scopes

Simple explanation, demo/example.

~~~~
@@@ ruby
scope :by_title, -> title { where(title: title) if title.present? }
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
def self.by_title title
  if title.present?
    where(title: title)
  else
    all
  end
end
~~~~

But that's nasty, don't you think? Let's do it

### Ruby style:

~~~~
@@@ ruby
def self.by_title title
  where(title: title) if title.present? or all
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


# Scope-to-class method chaining

# Class method-to-scope chaining

# Class method-to-class method chaining


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


# Moar?



# Even moar?

# Haha! No moar!

### The end

For now.

Thanks for your attention.
