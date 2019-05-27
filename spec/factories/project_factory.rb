require_relative 'member_factory'

FactoryBot.define do
  factory :project, class: 'CodePraise::Database::ProjectOrm' do
    origin_id { 184028231 }
    name {'codepraise-api'}
    size { 551 }
    ssh_url { 'git://github.com/XuVic/YPBT-app.git' }
    http_url { 'https://github.com/RubyStarts3/YPBT-api' }
    association :owner, factory: :member
    initialize_with { CodePraise::Database::ProjectOrm.find(origin_id: 184028231) || CodePraise::Database::ProjectOrm.create(attributes) }

    # after(:create) do |project|
    #   contributors = [
    #     {
    #       origin_id: 8809778,
    #       username: 'Yuan-Yu',
    #       email: 'Yuan-Yu@gmailrequ.com'
    #     },
    #     {
    #       origin_id: 22166763,
    #       username: 'SOA-KunLin',
    #       email: 'SOA-KunLin@gmail.com'
    #     },
    #     {
    #       origin_id: 17100800,
    #       username: 'luyimin',
    #       email: 'luyimin@gmail.com'
    #     }
    #   ]
    #   contributors.each do |contributor|
    #     contributor_record = FactoryBot.create(:member, origin_id: contributor[:origin_id], username: contributor[:username], email: contributor[:email])
    #     project.add_contributor(contributor_record)
    #   end
    # end
  end
end