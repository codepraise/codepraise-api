# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/measurement_helper'
require_relative '../../helpers/database_helper.rb'

describe 'File-Level Measurement' do
  DatabaseHelper.setup_database_cleaner

  before do
    DatabaseHelper.wipe_database
    project = create(:project)
    @measurement_helper = MeasurementHelper.new(project)
    @measurement_helper.setup_project
    @file_contributions = @measurement_helper.ruby_file
  end

  after do
    @measurement_helper.delete_project?
  end

  describe CodePraise::Entity::FileContributions do
    describe 'Measure File Quality' do
      it 'should calculate average complexity and give a complexity level'do
      end

      it 'should calculate complexity for each methods' do
      end

      it 'should calculate total offenses of idiomaticity' do
      end

      it 'should calculate test coverage' do

      end

      it 'should calculate documentation ratio' do
      end
    end

    describe 'Measure File Size' do
      it 'should calculate number of line of code' do
      end

      it 'should calculate number of method' do
      end

      it 'should calculate number of comment' do
      end
    end
  end
end
