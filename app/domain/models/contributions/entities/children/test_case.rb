# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module CodePraise
  module Entity
    class TestCase < Dry::Struct
      KEY_WORD = 'Security'
      include Dry::Types.module

      attribute :message, Strict::String

      def is_functionality
        !(message =~ /#{KEY_WORD}/).nil?
      end
    end
  end
end
