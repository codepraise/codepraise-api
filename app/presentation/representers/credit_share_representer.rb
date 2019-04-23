# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'contributor_representer'

module CodePraise
  module Representer
    # Represents a CreditShare value
    class CreditShare < Roar::Decorator
      include Roar::JSON

      property :line_credits
      property :line_percentage
      property :quality_credits
      property :collective_ownership
      property :method_credits
      collection :contributors, extend: Representer::Contributor,
                                class: OpenStruct
    end
  end
end
