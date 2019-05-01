require 'rails_helper'

RSpec.describe Task, type: :model do
  let!(:task) { create(:task) }

  context 'active task scope' do
    it 'should not allow to create task without title' do
      expect { described_class.create! }.to raise_error(
        ActiveRecord::RecordInvalid, "Validation failed: Title can't be blank"
      )
    end

    it 'should not allow to create task with existing title' do
      expect { described_class.create!(title: task.title) }.to raise_error(
        ActiveRecord::RecordInvalid, 'Validation failed: Title has already been taken'
      )
    end

    it 'should create nested tags by passing its title' do
      task.assign_attributes({ tags: ['task_1_tag_1', 'task_1_tag_2'] })
      expect { task.save! }.not_to raise_error
      expect(task.tags.count).to eq(2)
      expect(task.tags.first.title).to eq('task_1_tag_1')
      expect(task.tags.last.title).to eq('task_1_tag_2')
    end
  end

  context 'inactive task scope' do
    it 'should soft delete task and allow to use its title for new task' do
      task.mark_as_deleted!
      expect(task.deleted_at).not_to eq(nil)
      expect { described_class.create!(title: task.title) }.not_to raise_error
    end

    it 'should not list delete tasks in active scope' do
      expect(described_class.active).to eq([task])
      task.mark_as_deleted!
      expect(described_class.active).to eq([])
    end
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
