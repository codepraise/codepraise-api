# frozen_string_literal: true

require_relative 'project_representer'

# Represents essential Repo information for API output
module CodePraise
  module Representer
    class Comment < Roar::Decorator
      include Roar::JSON

      property :type
      property :is_documentation
      property :line_credits
    end
  end
end
