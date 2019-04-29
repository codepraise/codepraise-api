# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/measurement_helper'
require_relative '../../helpers/database_helper.rb'

describe 'File-Level Measurement' do
  DatabaseHelper.setup_database_cleaner

  before do
    @measurement_helper = MeasurementHelper.setup
    @folder_contributions = @measurement_helper.folder_contributions
    @file = @measurement_helper.file
    @anthor_file = @folder_contributions.files[0]
    @credit_share = CodePraise::Value::CreditShare.build_object(@file)
    binding.pry
  end

  after do
    DatabaseHelper.wipe_database
  end

  describe '' do
    it do
    end
  end
end
