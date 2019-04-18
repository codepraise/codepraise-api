# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/measurement_helper'
require_relative '../../helpers/database_helper'

describe CodePraise::Entity::Complexity do
  DatabaseHelper.setup_database_cleaner

  before do
    @measurement_helper = MeasurementHelper.setup
    @complexity = CodePraise::Mapper::Complexity
      .new(@measurement_helper.file_path).build_entity
  end

  after do
    DatabaseHelper.wipe_database
  end

  describe '#average' do
    it 'calculate average ABC score for a file' do
      _(@complexity.average).must_be_kind_of Float
      _(@complexity.average).must_be :>=, 0
    end
  end

  describe '#methods' do
    it 'calculate ABC score for each methods' do
      _(@complexity.methods).must_be_kind_of Hash
      _(@complexity.methods.values.reduce(&:+)).must_be :>=, 0
      average_score = @complexity.methods.values.reduce(&:+) / @complexity.methods.values.length
      _(average_score).must_equal @complexity.average
    end
  end

  describe '#level' do
    it 'show the level of complexity' do
      _(%w[A B C D E F]).must_include @complexity.level
    end
  end
end
