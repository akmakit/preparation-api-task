require 'rails_helper'

RSpec.describe Tag, type: :model do
  let!(:tag) { create(:tag) }

  context 'active tag scope' do
    it 'should not allow to create tag without title' do
      expect { described_class.create! }.to raise_error(
        ActiveRecord::RecordInvalid, "Validation failed: Title can't be blank"
      )
    end

    it 'should not allow to create tag with existing title' do
      expect { described_class.create!(title: tag.title) }.to raise_error(
        ActiveRecord::RecordInvalid, 'Validation failed: Title has already been taken'
      )
    end

    it 'should create nested tasks by passing its titles' do
      tag.assign_attributes({ tasks: ['tag_1_task_1', 'tag_1_task_2'] })
      expect { tag.save! }.not_to raise_error
      expect(tag.tasks.count).to eq(2)
      expect(tag.tasks.first.title).to eq('tag_1_task_1')
      expect(tag.tasks.last.title).to eq('tag_1_task_2')
    end
  end

  context 'inactive tag scope' do
    it 'should soft delete tag and allow to use its title for new tag' do
      tag.mark_as_deleted!
      expect(tag.deleted_at).not_to eq(nil)
      expect { described_class.create!(title: tag.title) }.not_to raise_error
    end

    it 'should not list delete tags in active scope' do
      expect(described_class.active).to eq([tag])
      tag.mark_as_deleted!
      expect(described_class.active).to eq([])
    end
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
