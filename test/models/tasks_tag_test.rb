require 'test_helper'

class TasksTagTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
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
