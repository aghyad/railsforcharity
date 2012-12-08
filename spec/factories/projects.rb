# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project do
    name { Faker.name }
    title 'Open Source Web based App'
    description 'To build open source web based applications which help in improving the society.'
    profile_url 'railsforcharity'

    creator

    factory :project_same_category_and_technology do
      category_names 'Rails'
      technology_names 'Rails'
    end

    factory :project_with_tags do
      category_names 'Citizen Activism, Affordable Transportation'
      technology_names 'Ruby on Rails, jQuery'
    end
  end
end
