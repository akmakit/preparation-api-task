class TasksTag < ApplicationRecord
  belongs_to :task
  belongs_to :tag
end

# == Schema Information
#
# Table name: tasks_tags
#
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  tag_id     :integer
#  task_id    :integer
#  updated_at :datetime         not null
#
