# frozen_string_literal: true

require_relative '../helpers/spec_helper'
require 'mongo'

describe CodePraise::Database::ProjectFolderContributionsOdm do
  before do
    @collection = Mongo::Client.new(CodePraise::Api.config.MONGODB_URL)['project_folder_contributions']
    @collection.drop
    @document = {test: 'test'}
    @collection.insert_one(@document)
  end

  describe 'self#find' do
    it 'recieve hash as condition to find specific document in collection' do
      project_folder_contributions = CodePraise::Database::ProjectFolderContributionsOdm
        .find(@document)
      _(project_folder_contributions).must_be_kind_of Array
      _(project_folder_contributions[0].document.include?('test'))
        .must_equal true
    end
  end

  describe '#update' do
    it 'should update document and change the instance variable document' do
      project_folder_contribution = CodePraise::Database::ProjectFolderContributionsOdm
        .new(@document)
      project_folder_contribution.update(test2: 'test2')
      _(project_folder_contribution.document)
        .must_equal @document.merge!(test: 'test2')
    end
  end

  describe '#insert' do
    it 'should insert the document into collection' do
      project_folder_contribution = CodePraise::Database::ProjectFolderContributionsOdm
        .new(test: 'test2')
      project_folder_contribution.save
      _(@collection.find(test: 'test2').first).wont_be_nil
    end
  end

  describe '#delete' do
    it 'should delete the document in the collection' do
      project_folder_contribution = CodePraise::Database::ProjectFolderContributionsOdm
        .new(@document)
      project_folder_contribution.delete
      _(@collection.find(@document).first).must_be_nil
    end
  end
end
