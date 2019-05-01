require 'rails_helper'

RSpec.describe Api::V1::TaskSerializer do
  let!(:task) { create(:task) }
  let!(:tag) { create(:tag)}

  it 'Should not raise any errors and return serialized values' do
    expect { described_class.new(task).as_json }.to_not raise_error
    expect(described_class.new(task).as_json).to eq(
      {
        id: task.id,
        title: task.title,
        tags: []
      }
    )
  end

  it 'Should return serialized values and nested attributes' do
    TasksTag.create!(task: task, tag: tag)
    task.reload

    expect(described_class.new(task).as_json).to eq(
      {
        id: task.id,
        title: task.title,
        tags: [
          {
            id: tag.id,
            title: tag.title
          }
        ]
      }
    )
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
