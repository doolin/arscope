# frozen_string_literal: true

# TODO: explain why we want to extend rather than include,
# and how that implies a scope is not much different than
# a regular Ruby class method.
# extend LocalScoper
class Invoice < ActiveRecord::Base
  belongs_to :order

  scope :bar, -> { where(name: 'Invoice 1') }
  scope :bar, -> { where(name: 'Invoice 2') } do
    'foo'
  end

  class << self
    def valid_scope_name?(name)
      raise "Overwriting scope #{name}" if respond_to?(name, true)
    end
  end
end
