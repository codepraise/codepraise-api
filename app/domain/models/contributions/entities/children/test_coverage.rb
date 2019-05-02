# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module CodePraise
  module Entity
    class TestCoverage < Dry::Struct
      include Dry::Types.module

      attribute :coverage, Coercible::Float
      attribute :time, Strict::Time
    end
  end
end
