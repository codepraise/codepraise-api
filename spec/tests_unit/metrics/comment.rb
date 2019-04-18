# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/measurement_helper'
require_relative '../../helpers/database_helper'

describe CodePraise::Entity::Complexity do
  DatabaseHelper.setup_database_cleaner

  before do
    @measurement_helper = MeasurementHelper.setup

    @comments = CodePraise::Mapper::Comments
      .new(@measurement_helper.folder_contributions.files[0].lines,
           @measurement_helper.folder_contributions.files[0].file_path).build_entities
  end

  after do
    DatabaseHelper.wipe_database
  end

  describe '#lines' do
    it 'collect lines of comment' do
      _(@comments[0].lines[0]).must_be_kind_of CodePraise::Entity::LineContribution
    end
  end

  describe '#type' do
    it { _(%w[multi-line single-line]).must_include @comments[0].type }
  end

  describe '#is_documentation' do
    it { _([true, false]).must_include @comments[0].is_documentation }
  end

  describe '#credit_share' do
    it 'show the contribution information of comment' do
      _(@measurement_helper.contributors)
        .must_include @comments[0].credit_share.keys[0]
      _(@comments[0].credit_share.values.reduce(&:+))
        .must_equal @comments[0].lines.size
    end
  end
end
