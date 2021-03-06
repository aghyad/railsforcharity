# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :task do
    name { words(2) }
    description { words(40) }
    task_type { ['chore', 'feature', 'bug', 'release'].sample }
    category Task::CATEGORIES[:programming]
    status Task::STATUSES[:open]
    estimated_time 4
    project_id 1
  end
end
