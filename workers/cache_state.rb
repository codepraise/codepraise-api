# frozen_string_literal: true

require_relative '../init.rb'

module Appraisal
  class CacheState
    def initialize(cache)
      @cache = cache
    end

    def cloning?
      %w[cloning cloned appraising appraised stored].include?(@cache.state)
    end

    def cloned?
      %w[cloned appraising appraised stored].include?(@cache.state)
    end

    def appraising?
      %w[appraising appraised stored].include?(@cache.state)
    end

    def appraised?
      %w[appraised stored].include?(@cache.state)
    end

    def stored?
      @cache.state == 'stored'
    end

    def update_state(state)
      data = { state: state }
      @cache = CodePraise::Repository::Appraisal
        .update(id: @cache.id, data: data)
    end
  end
end
