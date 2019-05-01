class Task < ApplicationRecord
  validates_presence_of :title
  validates_uniqueness_of :title, conditions: -> { where(deleted_at: nil) }, unless: :deleted_at_changed?

  has_many :tasks_tags
  has_many :tags, -> { active }, through: :tasks_tags, dependent: :destroy

  scope :active, -> { where(deleted_at: nil) }

  accepts_nested_attributes_for :tags

  def mark_as_deleted!
    update!(deleted_at: Time.zone.now)
  end

  def tags=(value)
    self.tags_attributes= value.map { |val| { title: val } }
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
