class Animal < ActiveRecord::Base
  # TODO: explain why we want to extend rather than include,
  # and how that implies a scope is not much different than
  # a regular Ruby class method.
  # At the moment, this is blowing up the stack and I don't know why.
  #extend LocalScoper

  belongs_to :farm

  scope :needs_vet, -> { where("last_vet < ?", 1.year.ago) }

  scope :pets, -> { where(role: 'pet') }

  #scope :bar, -> { where(name: "animal 4") }
  #scope :bar, -> { where(name: "animal 4") }

  ##  Why can't we use 'type' here?
  #scope :is, -> (kind) { where(type: kind) }
  scope :by_kind, -> (kind) { where(kind: kind) }

  scope :by_name, -> (n) { where(name: n) }

  scope :badscope, -> { where("? - date.now.to_i > max_value", Time.now.utc.to_i) }

  #scope :by_breed, -> (breed) { where(breed: breed) if breed.present? }

  def self.working
    where(kind: 'working')
  end

  def self.show
    # Where is `where` defined in ActiveRecord?
    where(kind: 'show')
  end

  # Check behavior of the following against the scope above.
  # Something isn't quite right.
  def self.by_breed breed
    where(breed: breed) if breed.present? or all
  end

  def self.by_role role
    where(role: role) if role.present? or all
  end

  protected
  class << self
    def valid_scope_name? name
      if respond_to?(name, true)
        raise "Overwriting scope #{name}"
      end
    end
  end
end

