FactoryBot.define do
  factory :tag do
    sequence(:title) { |n| "Title_#{n}" }
  end
end

# == Schema Information
#
# Table name: tags
#
#  created_at :datetime         not null
#  deleted_at :datetime
#  id         :integer          not null, primary key
#  title      :string
#  updated_at :datetime         not null
#
