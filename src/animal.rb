class Animal < ActiveRecord::Base
  # TODO: explain why we want to extend rather than include,
  # and how that implies a scope is not much different than
  # a regular Ruby class method.
  #extend LocalScoper

  belongs_to :farm

  scope :foo, -> { where(name: "animal 4") }

  scope :bar, -> { where(name: "animal 4") }

  ##  Why can't we use 'type' here?
  scope :count, -> (kind) { where(type: kind) }
=begin
  scope :bar, -> { where(name: "animal 2") } do
    "foo"
  end
=end

  protected
  class << self
    def valid_scope_name? name
      if respond_to?(name, true)
        raise "Overwriting scope #{name}"
      end
    end
  end
end

