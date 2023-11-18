# frozen_string_literal: true

# TODO: explain why we want to extend rather than include,
# and how that implies a scope is not much different than
# a regular Ruby class method.
# At the moment, this is blowing up the stack and I don't know why.
# extend LocalScoper
class Animal < ActiveRecord::Base
  belongs_to :farm

  scope :needs_vet, (-> { where('last_vet < ?', 1.year.ago) })

  scope :pets, (-> { where(role: 'pet') })

  # scope :bar, -> { where(name: "animal 4") }
  # scope :bar, -> { where(name: "animal 4") }

  ##  Why can't we use 'type' here?
  # scope :is, -> (kind) { where(type: kind) }
  scope :by_kind, (->(kind) { where(kind:) }) do
    def work(kind)
      'herd' if kind == 'dog'
    end
  end

  scope :by_name, (->(n) { where(name: n) })

  scope :badscope, (-> { where('? - date.now.to_i > max_value', Time.now.utc.to_i) })

  # scope :by_breed, -> (breed) { where(breed: breed) if breed.present? }

  scope :yielder, (-> { where(breed: 'persion') }) do
    def yieldit
      yield
    end
  end

  def self.working
    where(kind: 'working')
  end

  def self.show
    # Where is `where` defined in ActiveRecord?
    where(kind: 'show')
  end

  # Check behavior of the following against the scope above.
  # Something isn't quite right.
  def self.by_breed(breed)
    where(breed:) if breed.present? || all
  end

  def self.by_role(role)
    where(role:) if role.present? || all
  end

  class << self
    def valid_scope_name?(name)
      raise "Overwriting scope #{name}" if respond_to?(name, true)
    end
  end
end
