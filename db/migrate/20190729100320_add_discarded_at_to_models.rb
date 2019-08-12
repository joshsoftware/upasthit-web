# frozen_string_literal: true

class AddDiscardedAtToModels < ActiveRecord::Migration[5.2]
  def change
    add_column :students, :discarded_at, :datetime
    add_index :students, :discarded_at
    add_column :staffs, :discarded_at, :datetime
    add_index :staffs, :discarded_at
    add_column :attendances, :discarded_at, :datetime
    add_index :attendances, :discarded_at
    add_column :standard_attendances, :discarded_at, :datetime
    add_index :standard_attendances, :discarded_at
  end
end
