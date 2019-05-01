FactoryBot.define do
  factory :task do
    sequence(:title) { |n| "Title_#{n}" }
  end
end

# == Schema Information
#
# Table name: tasks
#
#  created_at :datetime         not null
#  deleted_at :datetime
#  id         :integer          not null, primary key
#  title      :string
#  updated_at :datetime         not null
#
