# frozen_string_literal: true

# Support for scoping talk.
class Farm < ActiveRecord::Base
  has_many :animals

  scope :long, -> { where('length > 1000') }
end
