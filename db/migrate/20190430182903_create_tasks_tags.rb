class CreateTasksTags < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks_tags do |t|
      t.integer :task_id
      t.integer :tag_id
      t.timestamps
    end

    add_index :tasks_tags, [:task_id, :tag_id]
  end
end
