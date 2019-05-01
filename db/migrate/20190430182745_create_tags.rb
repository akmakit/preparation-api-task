class CreateTags < ActiveRecord::Migration[5.2]
  def change
    create_table :tags do |t|
      t.string :title, default: nil
      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
