class Cave < ActiveRecord::Base
  # TODO: explain why we want to extend rather than include,
  # and how that implies a scope is not much different than
  # a regular Ruby class method.
  #extend LocalScoper

  belongs_to :hill

  scope :foo, -> { where(name: "Cave 4") }

  scope :bar, -> { where(name: "Cave 4") }
=begin
  scope :bar, -> { where(name: "Cave 2") } do
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


