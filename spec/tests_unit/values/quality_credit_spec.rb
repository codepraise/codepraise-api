# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/measurement_helper'
require_relative '../../helpers/database_helper'

describe CodePraise::Value::QualityCredit do
  DatabaseHelper.setup_database_cleaner
  DatabaseHelper.wipe_database

  before(:all) do
    @measurement_helper = MeasurementHelper.setup
    @file = @measurement_helper.file
    @quality_credits = CodePraise::Value::QualityCredit
      .build_object(@file.complexity, @file.idiomaticity, @file.comments)
    binding.pry
  end

  after do
    DatabaseHelper.wipe_database
  end

  it '' do

  end

  describe '#complexity' do
  end
  describe '#idiomaticity' do
  end
end
