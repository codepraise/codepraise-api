# frozen_string_literal: true


class MeasurementHelper
  attr_reader :git_repo

  def initialize(project)
    @project = project
    @git_repo = CodePraise::GitRepo.new(project, CodePraise::Api.config)
  end

  def setup_project
    clone unless @git_repo.exists_locally?
  end

  def folder_measurement
    @folder_measurement ||= CodePraise::Mapper::Contributions.new(@git_repo).for_folder('')
  end

  def delete_project?
    puts 'Do you want to delete the test project?(yes/no)'
    ans = gets.chomp
    @git_repo.delete if %w[yes y].include?(ans)
  end

  def ruby_file_path
    "#{repo_path}/#{ruby_file}"
  end

  def repo_path
    @git_repo.local.git_repo_path
  end

  def file_blame
    blames = CodePraise::Git::BlameReporter.new(@git_repo).folder_report('')
    ruby_blame = blames.select { |b| b[0] == ruby_file }.first
    CodePraise::Mapper::BlamePorcelain.parse_file_blame(ruby_blame[1])
  end

  private

  def ruby_file
    @git_repo.local.files.select { |f| File.extname(f) == '.rb' }.first
  end

  def clone
    @git_repo.clone_locally do |line|
      puts line
    end
  end
end
