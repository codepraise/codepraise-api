FactoryBot.define do
  factory :member, class: "CodePraise::Database::MemberOrm" do
    origin_id { 1926704 }
    username { "soumyaray" }
    email { "soumyaray@gmail.com" }
    initialize_with { CodePraise::Database::MemberOrm.find(origin_id: origin_id) || CodePraise::Database::MemberOrm.create(attributes) }
  end
end